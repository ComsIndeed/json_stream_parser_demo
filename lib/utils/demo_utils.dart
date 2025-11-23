import 'dart:async';

Stream<String> getSimulatedLlmStream(String fullText,
    {int chunkSize = 2,
    Duration interval = const Duration(milliseconds: 50)}) async* {
  for (int i = 0; i < fullText.length; i += chunkSize) {
    int end =
        (i + chunkSize < fullText.length) ? i + chunkSize : fullText.length;
    yield fullText.substring(i, end);
    await Future.delayed(interval);
  }
}
