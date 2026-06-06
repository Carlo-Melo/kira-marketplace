import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../models/service_model.dart';

typedef BookingSchedulerSubmit =
    Future<void> Function(ServiceModel service, DateTime scheduledDateTime);

class BookingSchedulerSheet extends StatefulWidget {
  const BookingSchedulerSheet({
    super.key,
    required this.services,
    required this.onSubmit,
    this.initialService,
  });

  final List<ServiceModel> services;
  final BookingSchedulerSubmit onSubmit;
  final ServiceModel? initialService;

  static Future<void> show(
    BuildContext context, {
    required List<ServiceModel> services,
    required BookingSchedulerSubmit onSubmit,
    ServiceModel? initialService,
  }) async {
    final width = MediaQuery.sizeOf(context).width;
    final useDialog = kIsWeb || width >= 720;

    if (useDialog) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: BookingSchedulerSheet(
                services: services,
                onSubmit: onSubmit,
                initialService: initialService,
              ),
            ),
          );
        },
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: BookingSchedulerSheet(
                  services: services,
                  onSubmit: onSubmit,
                  initialService: initialService,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<BookingSchedulerSheet> createState() => _BookingSchedulerSheetState();
}

class _BookingSchedulerSheetState extends State<BookingSchedulerSheet> {
  ServiceModel? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedService =
        widget.initialService ??
        (widget.services.isNotEmpty ? widget.services.first : null);
  }

  DateTime get _selectedDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  Future<void> _submit() async {
    final service = _selectedService;
    if (service == null) return;
    await widget.onSubmit(service, _selectedDateTime);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String get _summaryLabel => formatDateTime(_selectedDateTime);

  @override
  Widget build(BuildContext context) {
    if (widget.services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum servico disponivel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Este profissional ainda nao possui servicos ativos para agendamento.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final body = isWide
            ? _buildWideLayout(context)
            : _buildCompactLayout(context);

        return AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isWide ? 28 : 18,
              isWide ? 28 : 18,
              isWide ? 28 : 18,
              isWide ? 28 : 18,
            ),
            child: body,
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: 'Novo agendamento',
          subtitle: 'Escolha servico, data e horario em um fluxo unico.',
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildServicePanel(context)),
            const SizedBox(width: 20),
            Expanded(child: _buildCalendarPanel(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: 'Novo agendamento',
          subtitle: 'Fluxo otimizado para web e mobile.',
        ),
        const SizedBox(height: 18),
        _buildServicePanel(context),
        const SizedBox(height: 16),
        _buildCalendarPanel(context),
      ],
    );
  }

  Widget _buildServicePanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servico',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceModel>(
              key: ValueKey<int?>(_selectedService?.id),
              initialValue: _selectedService,
              decoration: const InputDecoration(labelText: 'Escolha o servico'),
              items: widget.services
                  .map(
                    (service) => DropdownMenuItem<ServiceModel>(
                      value: service,
                      child: Text(service.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedService = value);
              },
            ),
            const SizedBox(height: 16),
            if (_selectedService != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedService!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedService!.description.isEmpty
                          ? 'Sem descricao adicional.'
                          : _selectedService!.description,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          icon: Icons.payments_outlined,
                          label: formatMoney(_selectedService!.price),
                        ),
                        _Pill(
                          icon: Icons.schedule_outlined,
                          label: '${_selectedService!.durationMinutes} min',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Resumo',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              dateLabel: _summaryLabel,
              serviceLabel: _selectedService?.name ?? 'Selecione um servico',
              priceLabel: _selectedService == null
                  ? '-'
                  : formatMoney(_selectedService!.price),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarPanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data e horario',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 120)),
                onDateChanged: (value) {
                  setState(() => _selectedDate = value);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Horario',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: _buildTimeChips()),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedService == null ? null : _submit,
                icon: const Icon(Icons.event_available),
                label: const Text('Agendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeChips() {
    final slots = <TimeOfDay>[
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
    ];

    return slots.map((slot) {
      final selected =
          slot.hour == _selectedTime.hour &&
          slot.minute == _selectedTime.minute;
      return ChoiceChip(
        label: Text(slot.format(context)),
        selected: selected,
        onSelected: (_) => setState(() => _selectedTime = slot),
      );
    }).toList();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

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
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0D7E71)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.dateLabel,
    required this.serviceLabel,
    required this.priceLabel,
  });

  final String dateLabel;
  final String serviceLabel;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF1ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('Data: $dateLabel'),
          const SizedBox(height: 4),
          Text('Preco: $priceLabel'),
        ],
      ),
    );
  }
}
