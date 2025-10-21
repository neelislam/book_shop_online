import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTrackingSystem extends StatelessWidget {
  const OrderTrackingSystem({super.key});

  static const Map<String, String> _valueToTranslationKey = {
    'pending': 'status_pending',
    'মুলতুবি': 'status_pending',
    'processing': 'status_processing',
    'প্রক্রিয়াকরণ': 'status_processing',
    'shipped': 'status_shipped',
    'প্রেরিত': 'status_shipped',
    'out for delivery': 'out_for_delivery',
    'ডেলিভারির জন্য প্রস্তুত': 'out_for_delivery',
    'delivered': 'status_delivered',
    'বিতরিত': 'status_delivered',
  };

  Widget _buildTimelineItem({
    required String status,
    required String date,
    required String descriptionKey,
    required bool isComplete,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final normalizedStatus = status.trim().toLowerCase();
    final statusKey = _valueToTranslationKey[normalizedStatus] ?? 'status_unknown';

    if (statusKey == 'status_unknown') {
      debugPrint('⚠️ Unknown order status: "$status" (normalized: "$normalizedStatus")');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  gradient: isComplete
                      ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  )
                      : null,
                  color: isComplete ? null : const Color(0xFFE5E7EB),
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isComplete
                    ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
                    : null,
                color: isComplete ? null : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
                boxShadow: isComplete
                    ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: isComplete
                  ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  gradient: isComplete
                      ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  )
                      : null,
                  color: isComplete ? null : const Color(0xFFE5E7EB),
                ),
              ),
          ],
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16, bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isComplete ? const Color(0xFF6366F1).withOpacity(0.3) : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isComplete
                      ? const Color(0xFF6366F1).withOpacity(0.1)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusKey.tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isComplete ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date == 'N/A' ? 'na'.tr : date,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isComplete ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  descriptionKey.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: isComplete ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'track_order'.tr,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Order Status Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Out for Delivery',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Timeline
                  _buildTimelineItem(
                    status: 'Pending',
                    date: '2023-10-26',
                    descriptionKey: 'order_placed_description',
                    isComplete: true,
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    status: 'Shipped',
                    date: '2023-10-27',
                    descriptionKey: 'shipped_description',
                    isComplete: true,
                  ),
                  _buildTimelineItem(
                    status: 'Out for Delivery',
                    date: '2023-10-28',
                    descriptionKey: 'out_for_delivery_description',
                    isComplete: false,
                  ),
                  _buildTimelineItem(
                    status: 'Delivered',
                    date: 'N/A',
                    descriptionKey: 'delivered_description',
                    isComplete: false,
                    isLast: true,
                  ),

                  const SizedBox(height: 24),

                  // Back Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'ok'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
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
}