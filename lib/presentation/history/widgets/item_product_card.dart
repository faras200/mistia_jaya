import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_app/core/components/spaces.dart';
import 'package:flutter_pos_app/core/constants/colors.dart';
import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/core/extensions/int_ext.dart';
import 'package:flutter_pos_app/data/models/request/order_request_model.dart';
import 'package:flutter_pos_app/presentation/home/models/order_item.dart';

class ItemProductCard extends StatelessWidget {
  final OrderItem dataproduct;
  final OrderItemModel data;
  final EdgeInsetsGeometry? padding;

  const ItemProductCard({
    super.key,
    required this.data,
    required this.dataproduct,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          margin: padding,
          padding: const EdgeInsets.all(8.0),
          decoration: const ShapeDecoration(
            color: Colors.transparent,
            shape: Border(
              bottom: BorderSide(width: 2, color: Color(0xFFC7D0EB)),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                child: CachedNetworkImage(
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  imageUrl:
                      "${Variables.imageBaseUrl}${dataproduct.product.image}",
                  placeholder: (context, url) => Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.food_bank_outlined,
                    size: 46.0,
                  ),
                ),
              ),
              const SpaceWidth(24.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Text(
                            dataproduct.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Text(
                            '${data.quantity} x  @${dataproduct.product.price.currencyFormat}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight(20.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
