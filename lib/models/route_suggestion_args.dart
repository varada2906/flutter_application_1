// In your models/route_suggestion_args.dart file
import 'package:flutter/material.dart';

import 'transport_mode.dart';

class RouteSuggestionArgs {
  final String from;
  final String to;
  final TransportMode transportMode;

  RouteSuggestionArgs(this.from, this.to, this.transportMode);
}