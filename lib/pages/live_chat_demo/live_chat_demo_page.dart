import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:json_stream_parser_demo/pages/live_chat_demo/chat_provider.dart';
import 'package:json_stream_parser_demo/pages/live_chat_demo/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LiveChatDemoPage extends StatefulWidget {
  const LiveChatDemoPage({super.key});

  @override
  State<LiveChatDemoPage> createState() => _LiveChatDemoPageState();
}

class _LiveChatDemoPageState extends State<LiveChatDemoPage> {
  final geminiKeyController = TextEditingController();
  final groqKeyController = TextEditingController();
  final messageController = TextEditingController();

  String modelProvider = "Google";
  String modelName = "gemini-2.5-flash";

  void _showSettingsModal() {
    showModalBottomSheet(
        context: context,
        builder: (_) => BottomSheet(
            onClosing: () {},
            builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {},
                        title: Text("Gemini API Key"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Paste your Gemini API Key here if you want to use Google's Gemini models for testing"),
                            TextField(
                              controller: geminiKeyController,
                            )
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        title: Text("Groq API Key"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Paste your Gemini API Key here if you want to use Groq's LLM AI API for testing"),
                            TextField(
                              controller: groqKeyController,
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      Text('These are automatically saved and applied.')
                    ],
                  ),
                )));
  }

  void _showModelSelectionModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {},
            builder: (context) => Column(
                  children: models.keys
                      .map((modelProviderItem) => ExpansionTile(
                            title: Text(modelProviderItem),
                            children: models[modelProviderItem]!
                                .map((modelNameItem) => ListTile(
                                      title: Text(modelNameItem),
                                      onTap: () => setState(() {
                                        modelProvider = modelProviderItem;
                                        modelName = modelNameItem;
                                      }),
                                    ))
                                .toList(),
                          ))
                      .toList(),
                )));
  }

  void _onSubmitMessage(BuildContext context) {
    final message = messageController.text;
    if (message.isEmpty) return;

    context.read<ChatProvider>().sendMessage(
        message: message, modelProvider: modelProvider, modelName: modelName);
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      builder: (context, widget) => Center(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Live Chat Demo',
                  style: isMobile
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),
                IconButton(
                    onPressed: _showSettingsModal, icon: Icon(Icons.settings))
              ],
            ),
            Expanded(
              child: SizedBox.expand(
                  child: Card(
                child: Column(
                  children: [
                    TopBar(),
                    Expanded(
                        child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 4 : 16, vertical: 8),
                      itemCount:
                          Provider.of<ChatProvider>(context).messages.length,
                      itemBuilder: (context, index) {
                        final chatMessage =
                            Provider.of<ChatProvider>(context).messages[index];
                        return Align(
                          alignment: chatMessage.role == ChatMessageRole.user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isMobile ? double.infinity : 512,
                            ),
                            child: Card(
                              color: chatMessage.role == ChatMessageRole.user
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : chatMessage.role == ChatMessageRole.model
                                      ? Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .errorContainer,
                              shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                                child: MarkdownBody(data: chatMessage.message),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: isMobile ? 100 : 120,
                        child: Card(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        onSubmitted:
                                            Provider.of<ChatProvider>(context)
                                                    .isGenerating
                                                ? null
                                                : (_) =>
                                                    _onSubmitMessage(context),
                                        controller: messageController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Type your message here'),
                                        style: TextStyle(
                                            fontSize: isMobile ? 14 : 16),
                                      ),
                                    ),
                                    IconButton.filled(
                                        onPressed:
                                            Provider.of<ChatProvider>(context)
                                                    .isGenerating
                                                ? null
                                                : () =>
                                                    _onSubmitMessage(context),
                                        icon: Icon(Icons.arrow_upward))
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                          onPressed: _showModelSelectionModal,
                                          child: Text(
                                            modelName,
                                            style: TextStyle(
                                                fontSize: isMobile ? 11 : 14),
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
            SizedBox(height: isMobile ? 60 : 40),
          ],
        ),
      ),
    );
  }
}
