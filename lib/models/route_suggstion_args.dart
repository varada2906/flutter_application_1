// In models/route_suggestion_args.dart

// Add this enum
enum TransportMode { bus, train, metro }

class RouteSuggestionArgs {
  final String from;
  final String to;
  final TransportMode transportMode; // Add this field

  // Update constructor to include transportMode
  RouteSuggestionArgs(this.from, this.to, this.transportMode);
}