import 'package:llm_json_stream/json_stream_parser.dart';

/// Extensions to simulate the new API syntax proposed for v0.2.0+
/// This allows us to write the demo code using the new syntax before the package is updated.
extension JsonStreamParserShortcuts on JsonStreamParser {
  StringPropertyStream str(String path) => getStringProperty(path);
  NumberPropertyStream number(String path) => getNumberProperty(path);
  BooleanPropertyStream bool(String path) => getBooleanProperty(path);
  NullPropertyStream nil(String path) => getNullProperty(path);
  MapPropertyStream map(String path) => getMapProperty(path);
  ListPropertyStream list(String path,
      {void Function(PropertyStream property, int index)? onElement}) {
    if (onElement != null) {
      return getListProperty(path, onElement: onElement);
    }
    return getListProperty(path);
  }
}

extension PropertyStreamSmartCasts on PropertyStream {
  MapPropertyStream get asMap => this as MapPropertyStream;
  ListPropertyStream get asList => this as ListPropertyStream;
  StringPropertyStream get asStr => this as StringPropertyStream;
  NumberPropertyStream get asNum => this as NumberPropertyStream;
  BooleanPropertyStream get asBool => this as BooleanPropertyStream;
}

extension MapPropertyStreamShortcuts on MapPropertyStream {
  StringPropertyStream str(String path) => getStringProperty(path);
  NumberPropertyStream number(String path) => getNumberProperty(path);
  BooleanPropertyStream bool(String path) => getBooleanProperty(path);
  NullPropertyStream nil(String path) => getNullProperty(path);
  MapPropertyStream map(String path) => getMapProperty(path);
  ListPropertyStream list(String path,
      {void Function(PropertyStream property, int index)? onElement}) {
    if (onElement != null) {
      return getListProperty(path, onElement: onElement);
    }
    return getListProperty(path);
  }
}

extension ListPropertyStreamShortcuts on ListPropertyStream {
  // Note: List property access usually requires an index in the path or chaining
  // But these helpers might be useful for direct access if supported by the parser

  // We can also add the onElement alias here if needed, but it's a method on the class already
  // void onElement(void Function(PropertyStream element, int index) callback) => this.onElement(callback);
}
