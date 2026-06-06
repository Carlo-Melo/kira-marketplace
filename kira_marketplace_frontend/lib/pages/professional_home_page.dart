import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatters.dart';
import '../models/booking_model.dart';
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
import '../widgets/loading_widget.dart';

class ProfessionalHomePage extends StatefulWidget {
  const ProfessionalHomePage({super.key});

  @override
  State<ProfessionalHomePage> createState() => _ProfessionalHomePageState();
}

class _ProfessionalHomePageState extends State<ProfessionalHomePage> {
  bool _isBootstrapped = false;
  ProfessionalModel? _currentProfessional;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final professionalProvider = context.read<ProfessionalProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    final authResponse = authProvider.authResponse;
    if (authResponse == null) return;

    await professionalProvider.loadAll();

    final currentProfessional = professionalProvider.professionals.where((
      professional,
    ) {
      return professional.user?.id == authResponse.userId ||
          professional.userId == authResponse.userId;
    }).toList();

    if (currentProfessional.isEmpty) {
      if (mounted) {
        setState(() {
          _currentProfessional = null;
          _isBootstrapped = true;
        });
      }
      return;
    }

    final professional = currentProfessional.first;
    final professionalId = professional.id;
    if (professionalId == null) {
      if (mounted) {
        setState(() {
          _currentProfessional = professional;
          _isBootstrapped = true;
        });
      }
      return;
    }

    await Future.wait([
      catalogProvider.loadByProfessionalId(professionalId),
      bookingProvider.loadByProfessionalId(professionalId),
      reviewProvider.loadByProfessionalId(professionalId),
      paymentProvider.loadAll(),
    ]);

    if (mounted) {
      setState(() {
        _currentProfessional = professional;
        _isBootstrapped = true;
      });
    }
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

  Future<void> _showServiceDialog({ServiceModel? service}) async {
    final professional = _currentProfessional;
    final professionalId = professional?.id;
    if (professionalId == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: service?.name ?? '');
    final descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    final priceController = TextEditingController(
      text: service == null ? '' : service.price.toStringAsFixed(2),
    );
    final durationController = TextEditingController(
      text: service == null ? '' : service.durationMinutes.toString(),
    );
    bool active = service?.active ?? true;
    final catalogProvider = context.read<CatalogProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(service == null ? 'Novo servico' : 'Editar servico'),
            content: Form(
              key: formKey,
              child: StatefulBuilder(
                builder: (dialogContext, setDialogState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Descricao',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Preco'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o preco';
                            }
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null) {
                              return 'Preco invalido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duracao em minutos',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a duracao';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Duracao invalida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ativo'),
                          value: active,
                          onChanged: (value) {
                            setDialogState(() {
                              active = value;
                            });
                          },
                        ),
                      ],
                    ),
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

      final payload = ServiceModel(
        id: service?.id,
        professionalId: professionalId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text.replaceAll(',', '.')),
        durationMinutes: int.parse(durationController.text.trim()),
        active: active,
      );

      if (service == null) {
        await catalogProvider.create(payload);
      } else {
        await catalogProvider.update(service.id!, payload);
      }

      if (!mounted) return;
      await catalogProvider.loadByProfessionalId(professionalId);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            service == null ? 'Servico criado.' : 'Servico atualizado.',
          ),
        ),
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      durationController.dispose();
    }
  }

  Future<void> _deleteService(ServiceModel service) async {
    if (service.id == null) return;
    final catalogProvider = context.read<CatalogProvider>();
    await catalogProvider.delete(service.id!);
    final professional = _currentProfessional;
    if (mounted && professional?.id != null) {
      await catalogProvider.loadByProfessionalId(professional!.id!);
    }
  }

  Future<void> _updateBookingStatus(BookingModel booking, String status) async {
    if (booking.id == null) return;
    final bookingProvider = context.read<BookingProvider>();
    await bookingProvider.update(
      booking.id!,
      BookingModel(
        clientId: booking.clientId,
        professionalId: booking.professionalId,
        serviceId: booking.serviceId,
        bookingDate: booking.bookingDate,
        status: status,
        price: booking.price,
      ),
    );
    final professional = _currentProfessional;
    if (mounted && professional?.id != null) {
      await bookingProvider.loadByProfessionalId(professional!.id!);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID':
      case 'COMPLETED':
        return Colors.green;
      case 'CONFIRMED':
        return Colors.teal;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authResponse = context.watch<AuthProvider>().authResponse;
    final professionalProvider = context.watch<ProfessionalProvider>();
    final catalogProvider = context.watch<CatalogProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final reviewProvider = context.watch<ReviewProvider>();

    if (authResponse == null) {
      return const Scaffold(body: Center(child: Text('Sessao expirada.')));
    }

    final professional = _currentProfessional;
    final professionalId = professional?.id;
    final services = catalogProvider.services;
    final bookings = bookingProvider.bookings;
    final reviews = reviewProvider.reviews;
    final payments = paymentProvider.payments.where((payment) {
      final bookingProfessionalId =
          payment.booking?.professionalId ?? payment.booking?.professional?.id;
      return bookingProfessionalId == professionalId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Profissional'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF0F766E),
                      child: Icon(Icons.work, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo, ${authResponse.name}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            professional == null
                                ? 'Carregando seu perfil profissional...'
                                : '${professional.city} | ${professional.documentType} ${professional.documentNumber}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_isBootstrapped && professionalProvider.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: LoadingWidget(text: 'Carregando painel...'),
            )
          else
            Expanded(
              child: DefaultTabController(
                length: 5,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      labelColor: const Color(0xFF0F766E),
                      indicatorColor: const Color(0xFF0F766E),
                      tabs: const [
                        Tab(text: 'Visao geral'),
                        Tab(text: 'Servicos'),
                        Tab(text: 'Agendamentos'),
                        Tab(text: 'Pagamentos'),
                        Tab(text: 'Avaliacoes'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildOverviewTab(
                            context,
                            professional,
                            services,
                            bookings,
                            reviews,
                          ),
                          _buildServicesTab(context, services, professionalId),
                          _buildBookingsTab(context, bookings),
                          _buildPaymentsTab(context, payments),
                          _buildReviewsTab(context, reviews),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    ProfessionalModel? professional,
    List<ServiceModel> services,
    List<BookingModel> bookings,
    List<ReviewModel> reviews,
  ) {
    if (professional == null) {
      return const Center(child: Text('Perfil profissional nao encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.bio.isEmpty
                        ? 'Sem bio cadastrada.'
                        : professional.bio,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _infoPill(Icons.location_city, professional.city),
                      _infoPill(Icons.place, professional.address),
                      _infoPill(
                        Icons.star,
                        professional.rating?.toStringAsFixed(1) ?? '0.0',
                      ),
                      _infoPill(
                        Icons.reviews,
                        '${professional.totalReviews ?? 0} avaliacoes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Servicos',
                  services.length.toString(),
                  Icons.storefront,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Agendamentos',
                  bookings.length.toString(),
                  Icons.event_note,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Avaliacoes',
                  reviews.length.toString(),
                  Icons.star_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Status',
                  professional.rating == null
                      ? '0.0'
                      : professional.rating!.toStringAsFixed(1),
                  Icons.insights,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(
    BuildContext context,
    List<ServiceModel> services,
    int? professionalId,
  ) {
    if (professionalId == null) {
      return const Center(child: Text('Perfil profissional indisponivel.'));
    }
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nenhum servico cadastrado.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _showServiceDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Novo servico'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length + 1,
        separatorBuilder: (separatorContext, separatorIndex) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _showServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Novo servico'),
              ),
            );
          }

          final service = services[index - 1];
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
                          service.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Chip(
                        label: Text(service.active ? 'Ativo' : 'Inativo'),
                        backgroundColor: service.active
                            ? const Color(0xFFE7F7F4)
                            : Colors.grey.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(service.description),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _infoPill(Icons.payments, formatMoney(service.price)),
                      _infoPill(
                        Icons.schedule,
                        '${service.durationMinutes} min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showServiceDialog(service: service),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _deleteService(service),
                        icon: const Icon(Icons.delete),
                        label: const Text('Excluir'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingsTab(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text('Nenhum agendamento para este profissional.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (separatorContext, separatorIndex) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
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
                          booking.service?.name ??
                              'Servico #${booking.serviceId}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Chip(
                        label: Text(booking.status),
                        backgroundColor: _statusColor(
                          booking.status,
                        ).withAlpha(30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Cliente: ${booking.client?.name ?? booking.clientId}'),
                  Text('Data: ${formatDateTime(booking.bookingDate)}'),
                  if (booking.price != null)
                    Text('Valor: ${formatMoney(booking.price)}'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: booking.status == 'CONFIRMED'
                            ? null
                            : () => _updateBookingStatus(booking, 'CONFIRMED'),
                        child: const Text('Confirmar'),
                      ),
                      OutlinedButton(
                        onPressed: booking.status == 'COMPLETED'
                            ? null
                            : () => _updateBookingStatus(booking, 'COMPLETED'),
                        child: const Text('Concluir'),
                      ),
                      OutlinedButton(
                        onPressed: booking.status == 'CANCELLED'
                            ? null
                            : () => _updateBookingStatus(booking, 'CANCELLED'),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTab(BuildContext context, List<PaymentModel> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Text('Nenhum pagamento associado aos seus servicos.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        separatorBuilder: (separatorContext, separatorIndex) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Card(
            child: ListTile(
              title: Text(formatMoney(payment.amount)),
              subtitle: Text(
                'Metodo: ${payment.method} | Status: ${payment.status}\n'
                'Agendamento: ${payment.bookingId}',
              ),
              isThreeLine: true,
              trailing: Chip(
                label: Text(payment.status),
                backgroundColor: _statusColor(payment.status).withAlpha(30),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context, List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return const Center(
        child: Text('Nenhuma avaliacao para este profissional.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        separatorBuilder: (separatorContext, separatorIndex) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.client?.name ?? 'Cliente #${review.clientId}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (starIndex) => Icon(
                            starIndex < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(review.comment),
                  const SizedBox(height: 8),
                  Text(
                    'Criado em ${formatDateTime(review.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0F766E)),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD4E7E3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F766E)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
