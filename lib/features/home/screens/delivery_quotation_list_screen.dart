import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/home/controllers/delivery_quotation_controller.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/no_data_screen.dart';

class DeliveryQuotationListScreen extends StatefulWidget {
  const DeliveryQuotationListScreen({super.key});

  @override
  State<DeliveryQuotationListScreen> createState() =>
      _DeliveryQuotationListScreenState();
}

class _DeliveryQuotationListScreenState
    extends State<DeliveryQuotationListScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();

    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerAnimController.forward();

    Get.find<DeliveryQuotationController>().getDeliveryQuotationList(1, false);

    scrollController.addListener(() {
      final controller = Get.find<DeliveryQuotationController>();
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          controller.quotationList != null &&
          !controller.isLoading) {
        int pageSize = (controller.totalSize! / 10).ceil();
        if (controller.offset < pageSize) {
          controller.getDeliveryQuotationList(controller.offset + 1, false);
        }
      }
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return status?.capitalize ?? '';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: GetBuilder<DeliveryQuotationController>(
        builder: (controller) {
          return CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Sticky gradient header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: FadeTransition(
                    opacity: _headerFadeAnim,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary,
                            primary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // decorative circles
                          Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.local_shipping_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'My Delivery Requests',
                                            style: robotoBold.copyWith(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                          if (controller.quotationList != null)
                                            Text(
                                              '${controller.quotationList!.length} request${controller.quotationList!.length == 1 ? '' : 's'} found',
                                              style: robotoRegular.copyWith(
                                                color:
                                                    Colors.white.withOpacity(0.75),
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              if (controller.quotationList == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.quotationList!.isEmpty)
                SliverFillRemaining(
                  child: NoDataScreen(text: 'no_data_found'.tr),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final quotation = controller.quotationList![index];
                        final statusColor = _statusColor(quotation.status);
                        final isLast =
                            index == controller.quotationList!.length - 1;

                        return _QuotationCard(
                          index: index,
                          quotation: quotation,
                          statusColor: statusColor,
                          statusIcon: _statusIcon(quotation.status),
                          statusLabel: _statusLabel(quotation.status),
                          formattedDate: _formatDate(quotation.createdAt),
                          isLast: isLast,
                          onViewDoc: () {
                            if (quotation.imageFullUrl != null &&
                                quotation.imageFullUrl!.isNotEmpty) {
                              Get.toNamed(RouteHelper.getQuotationImageRoute(
                                  quotation.imageFullUrl!));
                            }
                          },
                        );
                      },
                      childCount: controller.quotationList!.length,
                    ),
                  ),
                ),
                if (controller.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Individual animated card ──────────────────────────────────────────────────

class _QuotationCard extends StatefulWidget {
  final int index;
  final dynamic quotation;
  final Color statusColor;
  final IconData statusIcon;
  final String statusLabel;
  final String formattedDate;
  final bool isLast;
  final VoidCallback onViewDoc;

  const _QuotationCard({
    required this.index,
    required this.quotation,
    required this.statusColor,
    required this.statusIcon,
    required this.statusLabel,
    required this.formattedDate,
    required this.isLast,
    required this.onViewDoc,
  });

  @override
  State<_QuotationCard> createState() => _QuotationCardState();
}

class _QuotationCardState extends State<_QuotationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 60),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Timeline rail ────────────────────────────────────────
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.statusColor.withOpacity(0.15),
                        border: Border.all(
                          color: widget.statusColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(widget.statusIcon,
                          color: widget.statusColor, size: 18),
                    ),
                    if (!widget.isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.statusColor.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Card body ────────────────────────────────────────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // colored top strip
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.statusColor,
                                widget.statusColor.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header row ───────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.quotation.id ?? '',
                                      style: robotoBold.copyWith(
                                        fontSize: 15,
                                        color: const Color(0xFF1A1A2E),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: widget.statusColor.withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: widget.statusColor,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          widget.statusLabel,
                                          style: robotoMedium.copyWith(
                                            fontSize: 11,
                                            color: widget.statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              const Divider(height: 1, thickness: 0.8),
                              const SizedBox(height: 10),

                              // ── Footer row ───────────────────────────
                              Row(
                                children: [
                                  // date
                                  if (widget.formattedDate.isNotEmpty) ...[
                                    Icon(Icons.calendar_today_rounded,
                                        size: 13,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.formattedDate,
                                      style: robotoRegular.copyWith(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],

                                  const Spacer(),

                                  // View document button
                                  if (widget.quotation.imageFullUrl != null)
                                    GestureDetector(
                                      onTap: widget.onViewDoc,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primary,
                                              primary.withOpacity(0.75),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  primary.withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.list_alt_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'View Items',
                                              style: robotoMedium.copyWith(
                                                fontSize: 11,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
