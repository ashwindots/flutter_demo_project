import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../models/country_model.dart';
import '../routes/app_routes.dart';
import '../utils/helpers.dart';

class CountryCard extends StatelessWidget {
  final CountryModel country;

  const CountryCard({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final CountryController controller = Get.find<CountryController>();
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.toNamed(AppRoutes.countryDetail, arguments: country),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Flag
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: country.flagUrl,
                  width: 64,
                  height: 44,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) =>
                      Container(
                        width: 64,
                        height: 44,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          Container(
                            width: 64,
                            height: 44,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.flag, size: 24),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.public,
                            size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          country.region,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people,
                            size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          formatPopulation(country.population),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (country.capital != 'N/A') ...[
                          const SizedBox(width: 12),
                          Icon(Icons.location_city,
                              size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              country.capital,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite button
              Obx(() => IconButton(
                    icon: Icon(
                      controller.isFavorite(country.cca3)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: controller.isFavorite(country.cca3)
                          ? Colors.red
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => controller.toggleFavorite(country.cca3),
                    visualDensity: VisualDensity.compact,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
