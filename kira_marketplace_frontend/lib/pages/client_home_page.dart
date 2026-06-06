import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatters.dart';
import '../models/booking_model.dart';
import '../models/auth_response_model.dart';
import '../models/payment_model.dart';
import '../models/professional_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/professional_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/booking_scheduler_sheet.dart';
import '../widgets/loading_widget.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final TextEditingController _searchController = TextEditingController();

  int _navigationIndex = 0;
  double _maxPrice = 500;
  String _selectedCity = 'Todas';
  bool _showActiveBookings = true;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final authResponse = authProvider.authResponse;
    if (authResponse == null) return;

    final professionalProvider = context.read<ProfessionalProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final reviewProvider = context.read<ReviewProvider>();

    await Future.wait([
      professionalProvider.loadAll(),
      catalogProvider.loadAll(),
      bookingProvider.loadByClientId(authResponse.userId),
      paymentProvider.loadAll(),
      reviewProvider.loadAll(),
    ]);

    if (!mounted) return;
    setState(() {
      _bootstrapped = true;
    });
  }

  Future<void> _refreshAll() async {
    await _bootstrap();
  }

  Future<void> _logout() async {
    context.read<AuthProvider>().clearState();
    context.read<CatalogProvider>().clearState();
    context.read<BookingProvider>().clearState();
    context.read<PaymentProvider>().clearState();
    context.read<ProfessionalProvider>().clearState();
    context.read<ReviewProvider>().clearState();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _scheduleProfessional(ProfessionalModel professional) async {
    final authResponse = context.read<AuthProvider>().authResponse;
    if (authResponse == null || professional.id == null) return;

    final catalogProvider = context.read<CatalogProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final services = _servicesForProfessional(professional.id!);
    final messenger = ScaffoldMessenger.of(context);

    if (services.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Este profissional ainda nao possui servicos ativos.'),
        ),
      );
      return;
    }

    await BookingSchedulerSheet.show(
      context,
      services: services,
      initialService: services.first,
      onSubmit: (service, scheduledDateTime) async {
        await bookingProvider.create(
          BookingModel(
            clientId: authResponse.userId,
            professionalId: professional.id!,
            serviceId: service.id!,
            bookingDate: scheduledDateTime,
            status: 'PENDING',
            price: service.price,
          ),
        );

        if (!mounted) return;
        await bookingProvider.loadByClientId(authResponse.userId);
        await catalogProvider.loadAll();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Agendamento criado para ${formatDateTime(scheduledDateTime)}',
            ),
          ),
        );
      },
    );
  }

  Future<void> _showServicesSheet(ProfessionalModel professional) async {
    final services = _servicesForProfessional(professional.id ?? -1);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.user?.name ?? 'Profissional',
                  style: Theme.of(sheetContext).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  professional.bio.isEmpty
                      ? _ProfessionalCard._locationLabel(professional)
                      : professional.bio,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                _LocationChip(
                  label: _ProfessionalCard._locationLabel(professional),
                ),
                const SizedBox(height: 16),
                if (services.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Nenhum servico cadastrado.')),
                  )
                else
                  ...services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          title: Text(service.name),
                          subtitle: Text(
                            '${service.description}\n${service.durationMinutes} min',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            formatMoney(service.price),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0D7E71),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: services.isEmpty
                        ? null
                        : () {
                            Navigator.of(sheetContext).pop();
                            _scheduleProfessional(professional);
                          },
                    icon: const Icon(Icons.event_available),
                    label: const Text('Agendar agora'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPaymentDialog(BookingModel booking) async {
    if (booking.id == null) return;

    final amountController = TextEditingController(
      text: (booking.price ?? 0).toStringAsFixed(2),
    );
    String method = 'PIX';
    final formKey = GlobalKey<FormState>();
    final paymentProvider = context.read<PaymentProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Registrar pagamento'),
            content: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (dialogContext, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Valor'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o valor';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Valor invalido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: method,
                        decoration: const InputDecoration(labelText: 'Metodo'),
                        items: const [
                          DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                          DropdownMenuItem(
                            value: 'CREDIT_CARD',
                            child: Text('Cartao de credito'),
                          ),
                          DropdownMenuItem(
                            value: 'DEBIT_CARD',
                            child: Text('Cartao de debito'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => method = value);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      await paymentProvider.create(
        PaymentModel(
          bookingId: booking.id!,
          amount: double.parse(amountController.text.replaceAll(',', '.')),
          method: method,
          status: 'PENDING',
        ),
      );

      if (!mounted) return;
      await paymentProvider.loadAll();
      messenger.showSnackBar(
        const SnackBar(content: Text('Pagamento registrado.')),
      );
    } finally {
      amountController.dispose();
    }
  }

  Future<void> _showReviewDialog(BookingModel booking) async {
    if (booking.id == null) return;

    final commentController = TextEditingController();
    int rating = 5;
    final formKey = GlobalKey<FormState>();
    final reviewProvider = context.read<ReviewProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Enviar avaliacao'),
            content: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (dialogContext, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: rating,
                        decoration: const InputDecoration(labelText: 'Nota'),
                        items: List.generate(
                          5,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              '${index + 1} estrela${index == 0 ? '' : 's'}',
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => rating = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Comentario',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Escreva um comentario';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Enviar'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      await reviewProvider.create(
        ReviewModel(
          bookingId: booking.id!,
          clientId: booking.clientId,
          professionalId: booking.professionalId,
          rating: rating,
          comment: commentController.text.trim(),
        ),
      );

      if (!mounted) return;
      await reviewProvider.loadAll();
      messenger.showSnackBar(
        const SnackBar(content: Text('Avaliacao enviada.')),
      );
    } finally {
      commentController.dispose();
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    if (booking.id == null) return;

    final authResponse = context.read<AuthProvider>().authResponse;
    final bookingProvider = context.read<BookingProvider>();
    await bookingProvider.update(
      booking.id!,
      BookingModel(
        clientId: booking.clientId,
        professionalId: booking.professionalId,
        serviceId: booking.serviceId,
        bookingDate: booking.bookingDate,
        status: 'CANCELLED',
        price: booking.price,
      ),
    );

    if (mounted && authResponse != null) {
      await bookingProvider.loadByClientId(authResponse.userId);
    }
  }

  Future<void> _setCity(String? city) async {
    setState(() {
      _selectedCity = city ?? 'Todas';
    });
  }

  void _clearMarketplaceFilters() {
    setState(() {
      _searchController.clear();
      _selectedCity = 'Todas';
      _maxPrice = 500;
    });
  }

  List<String> get _cityOptions {
    final professionals = context.read<ProfessionalProvider>().professionals;
    final cities =
        professionals
            .map((professional) => professional.city.trim())
            .where((city) => city.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Todas', ...cities];
  }

  List<ServiceModel> _servicesForProfessional(int professionalId) {
    return context
        .read<CatalogProvider>()
        .services
        .where((service) => service.professionalId == professionalId)
        .toList();
  }

  List<ProfessionalModel> _filteredProfessionals() {
    final query = _searchController.text.trim().toLowerCase();
    final professionalProvider = context.read<ProfessionalProvider>();
    final allProfessionals = professionalProvider.professionals;
    final catalogServices = context.read<CatalogProvider>().services;

    return allProfessionals.where((professional) {
      final services = catalogServices
          .where((service) => service.professionalId == professional.id)
          .toList();
      final cityMatches =
          _selectedCity == 'Todas' || professional.city == _selectedCity;
      final priceMatches =
          services.isEmpty ||
          services.any((service) => service.price <= _maxPrice);
      final textMatches =
          query.isEmpty ||
          professional.user?.name.toLowerCase().contains(query) == true ||
          professional.bio.toLowerCase().contains(query) ||
          professional.city.toLowerCase().contains(query) ||
          professional.address.toLowerCase().contains(query) ||
          services.any(
            (service) =>
                service.name.toLowerCase().contains(query) ||
                service.description.toLowerCase().contains(query),
          );
      return cityMatches && priceMatches && textMatches;
    }).toList();
  }

  List<BookingModel> _filteredBookings(bool onlyActive) {
    final bookings = context.read<BookingProvider>().bookings;
    if (onlyActive) {
      return bookings.where((booking) {
        return booking.status != 'COMPLETED' && booking.status != 'CANCELLED';
      }).toList();
    }
    return bookings.where((booking) {
      return booking.status == 'COMPLETED' || booking.status == 'CANCELLED';
    }).toList();
  }

  List<PaymentModel> _clientPayments(int userId) {
    return context.read<PaymentProvider>().payments.where((payment) {
      final bookingClientId =
          payment.booking?.clientId ?? payment.booking?.client?.id;
      return bookingClientId == userId;
    }).toList();
  }

  List<ReviewModel> _clientReviews(int userId) {
    return context.read<ReviewProvider>().reviews.where((review) {
      return review.clientId == userId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authResponse = context.watch<AuthProvider>().authResponse;
    final catalogProvider = context.watch<CatalogProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final professionalProvider = context.watch<ProfessionalProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final reviewProvider = context.watch<ReviewProvider>();

    if (authResponse == null) {
      return const Scaffold(body: Center(child: Text('Sessao expirada.')));
    }

    final professionals = _filteredProfessionals();
    final allBookings = bookingProvider.bookings;
    final activeBookings = _filteredBookings(true);
    final historicBookings = _filteredBookings(false);
    final clientPayments = _clientPayments(authResponse.userId);
    final clientReviews = _clientReviews(authResponse.userId);

    final isLoading =
        !_bootstrapped &&
        (professionalProvider.isLoading ||
            catalogProvider.isLoading ||
            bookingProvider.isLoading ||
            paymentProvider.isLoading ||
            reviewProvider.isLoading);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kira Marketplace'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationIndex,
        onDestinationSelected: (value) =>
            setState(() => _navigationIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Marketplace',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_off_outlined),
            selectedIcon: Icon(Icons.search_off_rounded),
            label: 'Profissionais',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: LoadingWidget(text: 'Carregando painel...'))
          : IndexedStack(
              index: _navigationIndex,
              children: [
                _buildMarketplaceTab(
                  authResponse,
                  professionals,
                  allBookings.length,
                ),
                _buildAgendaTab(allBookings, activeBookings, historicBookings),
                _buildProfessionalsTab(professionals),
                _buildProfileTab(authResponse, clientPayments, clientReviews),
              ],
            ),
    );
  }

  Widget _buildMarketplaceTab(
    AuthResponseModel authResponse,
    List<ProfessionalModel> professionals,
    int bookingsCount,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          _HeroCard(
            name: authResponse.name,
            subtitle:
                'Descubra profissionais, compare preços, veja a localização e agende tudo em poucos toques.',
            bookingsCount: bookingsCount,
            professionalsCount: professionals.length,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, cidade, endereço ou servico',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
            ),
          ),
          const SizedBox(height: 14),
          _buildFilterCard(),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Profissionais (${professionals.length})',
            actionLabel: 'Limpar filtros',
            onAction: _clearMarketplaceFilters,
          ),
          const SizedBox(height: 12),
          if (professionals.isEmpty)
            const _EmptyMarketplaceState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1080
                    ? 3
                    : constraints.maxWidth > 700
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: professionals.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: crossAxisCount == 1 ? 2.4 : 1.65,
                  ),
                  itemBuilder: (context, index) {
                    final professional = professionals[index];
                    return _ProfessionalCard(
                      professional: professional,
                      services: _servicesForProfessional(professional.id ?? -1),
                      onSchedule: () => _scheduleProfessional(professional),
                      onServices: () => _showServicesSheet(professional),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 18),
          _SectionHeader(title: 'Servicos em destaque'),
          const SizedBox(height: 12),
          ...professionals
              .take(3)
              .map(
                (professional) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CompactProfessionalRow(
                    professional: professional,
                    services: _servicesForProfessional(professional.id ?? -1),
                    onSchedule: () => _scheduleProfessional(professional),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    final cityOptions = _cityOptions;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final cityField = DropdownButtonFormField<String>(
                  key: ValueKey<String>(_selectedCity),
                  initialValue: _selectedCity,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                  items: cityOptions
                      .map(
                        (city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        ),
                      )
                      .toList(),
                  onChanged: _setCity,
                );

                final priceField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preço máximo: ${formatMoney(_maxPrice)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _maxPrice,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      label: formatMoney(_maxPrice),
                      onChanged: (value) => setState(() => _maxPrice = value),
                    ),
                  ],
                );

                return isWide
                    ? Row(
                        children: [
                          Expanded(child: cityField),
                          const SizedBox(width: 12),
                          Expanded(child: priceField),
                        ],
                      )
                    : Column(
                        children: [
                          cityField,
                          const SizedBox(height: 12),
                          priceField,
                        ],
                      );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _clearMarketplaceFilters,
                child: const Text('Limpar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaTab(
    List<BookingModel> allBookings,
    List<BookingModel> activeBookings,
    List<BookingModel> historicBookings,
  ) {
    final bookings = _showActiveBookings ? activeBookings : historicBookings;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          _PageHeader(
            title: 'Agendamentos',
            subtitle: 'Acompanhe seus compromissos, pagamentos e avaliações.',
          ),
          const SizedBox(height: 14),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.check_circle_outline),
                label: Text('Ativos'),
              ),
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.history),
                label: Text('Historico'),
              ),
            ],
            selected: {_showActiveBookings},
            onSelectionChanged: (values) {
              if (values.isEmpty) return;
              setState(() => _showActiveBookings = values.first);
            },
          ),
          const SizedBox(height: 14),
          if (bookings.isEmpty)
            const _EmptyAgendaState()
          else
            ...bookings.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BookingCard(
                  booking: booking,
                  onPay: booking.id == null
                      ? null
                      : () => _showPaymentDialog(booking),
                  onReview: booking.id == null
                      ? null
                      : () => _showReviewDialog(booking),
                  onCancel: booking.id == null
                      ? null
                      : () => _cancelBooking(booking),
                  canReview: booking.status == 'COMPLETED',
                  canPay:
                      booking.status == 'PENDING' ||
                      booking.status == 'CONFIRMED',
                ),
              ),
            ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Total de agendamentos',
            actionLabel: allBookings.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalsTab(List<ProfessionalModel> professionals) {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          const _PageHeader(
            title: 'Profissionais',
            subtitle:
                'Explore perfis com foco em avaliacao, cidade e servicos.',
          ),
          const SizedBox(height: 14),
          if (professionals.isEmpty)
            const _EmptyMarketplaceState()
          else
            ...professionals.map(
              (professional) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProfessionalCard(
                  professional: professional,
                  services: _servicesForProfessional(professional.id ?? -1),
                  onSchedule: () => _scheduleProfessional(professional),
                  onServices: () => _showServicesSheet(professional),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(
    AuthResponseModel authResponse,
    List<PaymentModel> payments,
    List<ReviewModel> reviews,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          const _PageHeader(
            title: 'Meu perfil',
            subtitle:
                'Confira suas informações e finalize a sessão quando quiser.',
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFC8F0E8),
                    child: Text(
                      authResponse.name.isNotEmpty
                          ? authResponse.name
                                .trim()
                                .split(' ')
                                .map((part) => part.isEmpty ? '' : part[0])
                                .take(2)
                                .join()
                                .toUpperCase()
                          : 'K',
                      style: const TextStyle(
                        color: Color(0xFF0D7E71),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authResponse.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(authResponse.role),
                        const SizedBox(height: 4),
                        Text(
                          'ID do usuario: ${authResponse.userId}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Pagamentos',
                  value: payments.length.toString(),
                  icon: Icons.payments_outlined,
                  color: const Color(0xFFBFE6E0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Avaliacoes',
                  value: reviews.length.toString(),
                  icon: Icons.reviews_outlined,
                  color: const Color(0xFFF4D9B3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFDFF1ED),
            child: ListTile(
              leading: const Icon(
                Icons.shield_outlined,
                color: Color(0xFF0D7E71),
              ),
              title: const Text('Conta ativa'),
              subtitle: const Text(
                'Seu acesso esta configurado para usar o marketplace.',
              ),
              trailing: FilledButton.tonal(
                onPressed: _logout,
                child: const Text('Sair'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionHeader(title: 'Suas ultimas avaliacoes'),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            const _EmptyAgendaState(message: 'Nenhuma avaliacao enviada ainda.')
          else
            ...reviews
                .take(4)
                .map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        title: Text('Profissional #${review.professionalId}'),
                        subtitle: Text(review.comment),
                        trailing: Text('${review.rating}/5'),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.name,
    required this.subtitle,
    required this.bookingsCount,
    required this.professionalsCount,
  });

  final String name;
  final String subtitle;
  final int bookingsCount;
  final int professionalsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD9F1EC), Color(0xFFF5FBFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF0D7E71),
                child: Icon(Icons.spa_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo, $name',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PillStat(
                label: 'Profissionais',
                value: professionalsCount.toString(),
              ),
              _PillStat(label: 'Agendamentos', value: bookingsCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.professional,
    required this.services,
    required this.onSchedule,
    required this.onServices,
  });

  final ProfessionalModel professional;
  final List<ServiceModel> services;
  final VoidCallback onSchedule;
  final VoidCallback onServices;

  @override
  Widget build(BuildContext context) {
    final rating = professional.rating ?? 0;
    final reviewCount = professional.totalReviews ?? 0;
    final averagePrice = services.isEmpty ? null : _minimumPrice(services);
    final servicePreview = services.isEmpty
        ? 'Sem servicos publicados'
        : services.first.name;
    final locationLabel = _locationLabel(professional);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onServices,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFCDEFE8),
                    child: Text(
                      _initials(professional.user?.name ?? professional.city),
                      style: const TextStyle(
                        color: Color(0xFF0D7E71),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.user?.name ?? 'Profissional',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          professional.bio.isEmpty
                              ? locationLabel
                              : professional.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _PillStat(label: locationLabel, value: 'Local'),
                  _PillStat(
                    label: '$reviewCount avaliacoes',
                    value: rating.toStringAsFixed(1),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Servico em destaque',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          servicePreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    averagePrice == null ? '-' : formatMoney(averagePrice),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D7E71),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onServices,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver servicos'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.event_available),
                      label: const Text('Agendar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _minimumPrice(List<ServiceModel> services) {
    return services
        .map((service) => service.price)
        .reduce((left, right) => left < right ? left : right);
  }

  static String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'K';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  static String _locationLabel(ProfessionalModel professional) {
    final city = professional.city.trim();
    final address = professional.address.trim();
    if (city.isEmpty && address.isEmpty) {
      return 'Localização não informada';
    }
    if (city.isEmpty) {
      return address;
    }
    if (address.isEmpty) {
      return city;
    }
    return '$city • $address';
  }
}

class _CompactProfessionalRow extends StatelessWidget {
  const _CompactProfessionalRow({
    required this.professional,
    required this.services,
    required this.onSchedule,
  });

  final ProfessionalModel professional;
  final List<ServiceModel> services;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final minPrice = services.isEmpty
        ? null
        : services
              .map((service) => service.price)
              .reduce((left, right) => left < right ? left : right);

    return Card(
      child: ListTile(
        onTap: onSchedule,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFCDEFE8),
          child: Text(
            _ProfessionalCard._initials(
              professional.user?.name ?? professional.city,
            ),
            style: const TextStyle(
              color: Color(0xFF0D7E71),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          professional.user?.name ?? 'Profissional',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(_ProfessionalCard._locationLabel(professional)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              professional.rating?.toStringAsFixed(1) ?? '0.0',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              minPrice == null ? '-' : formatMoney(minPrice),
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: const Icon(Icons.location_on_outlined, size: 18),
        label: Text(label),
        side: BorderSide(color: Colors.grey.shade300),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onPay,
    required this.onReview,
    required this.onCancel,
    required this.canPay,
    required this.canReview,
  });

  final BookingModel booking;
  final VoidCallback? onPay;
  final VoidCallback? onReview;
  final VoidCallback? onCancel;
  final bool canPay;
  final bool canReview;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.service?.name ?? 'Servico #${booking.serviceId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(
                  label: Text(booking.status),
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Profissional: ${booking.professional?.user?.name ?? booking.professionalId}',
            ),
            const SizedBox(height: 4),
            Text('Data: ${formatDateTime(booking.bookingDate)}'),
            if (booking.price != null) ...[
              const SizedBox(height: 4),
              Text(
                'Valor: ${formatMoney(booking.price)}',
                style: const TextStyle(
                  color: Color(0xFF0D7E71),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canPay)
                  OutlinedButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Pagar'),
                  ),
                if (canReview)
                  OutlinedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.star),
                    label: const Text('Avaliar'),
                  ),
                if (booking.status != 'CANCELLED')
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'PAID':
      case 'COMPLETED':
        return Colors.green;
      case 'CONFIRMED':
        return const Color(0xFF0D7E71);
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      default:
        return const Color(0xFFF28E2B);
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0D7E71)),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _EmptyMarketplaceState extends StatelessWidget {
  const _EmptyMarketplaceState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum profissional encontrado',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Ajuste os filtros ou tente outro termo de busca.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _EmptyAgendaState extends StatelessWidget {
  const _EmptyAgendaState({
    this.message = 'Ainda nao ha registros nesta lista.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Nada por aqui',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
