import 'package:flutter/material.dart';

String formatPopulation(int population) {
  if (population >= 1000000000) {
    return '${(population / 1000000000).toStringAsFixed(2)}B';
  } else if (population >= 1000000) {
    return '${(population / 1000000).toStringAsFixed(2)}M';
  } else if (population >= 1000) {
    return '${(population / 1000).toStringAsFixed(1)}K';
  }
  return population.toString();
}

String formatArea(double area) {
  if (area >= 1000000) {
    return '${(area / 1000000).toStringAsFixed(2)}M km²';
  } else if (area >= 1000) {
    return '${(area / 1000).toStringAsFixed(1)}K km²';
  }
  return '${area.toStringAsFixed(0)} km²';
}

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ),
  );
}
