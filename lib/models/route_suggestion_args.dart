// In your models/route_suggestion_args.dart file
import 'package:flutter/material.dart';

enum TransportMode { bus, train }

class RouteSuggestionArgs {
  final String from;
  final String to;
  final TransportMode transportMode;

  RouteSuggestionArgs(this.from, this.to, this.transportMode);
}