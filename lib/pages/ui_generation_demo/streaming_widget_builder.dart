import 'package:flutter/material.dart';

/// Base class for all streamable widgets
abstract class StreamableWidget {
  Widget build(BuildContext context, {bool isComplete = true});
}

/// Streaming Text widget
class StreamingText extends StreamableWidget {
  final String text;
  final TextStyle? style;

  StreamingText({required this.text, this.style});

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedOpacity(
      opacity: isComplete ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

/// Streaming Scaffold widget
class StreamingScaffold extends StreamableWidget {
  final String? pageId;
  final bool showAppBar;
  final String? appBarTitle;
  final StreamableWidget? child;

  StreamingScaffold({
    this.pageId,
    this.showAppBar = false,
    this.appBarTitle,
    this.child,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedOpacity(
      opacity: isComplete ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: Text(appBarTitle ?? ''),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              )
            : null,
        body: child?.build(context, isComplete: isComplete) ?? const SizedBox(),
      ),
    );
  }
}

/// Streaming ListView widget
class StreamingListView extends StreamableWidget {
  final List<StreamableWidget> children;

  StreamingListView({required this.children});

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedScale(
          scale: isComplete ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 300),
          child: children[index].build(context, isComplete: isComplete),
        );
      },
    );
  }
}

/// Streaming Column widget
class StreamingColumn extends StreamableWidget {
  final List<StreamableWidget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  StreamingColumn({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.map((child) {
        return AnimatedScale(
          scale: isComplete ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 300),
          child: child.build(context, isComplete: isComplete),
        );
      }).toList(),
    );
  }
}

/// Streaming Row widget
class StreamingRow extends StreamableWidget {
  final List<StreamableWidget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  StreamingRow({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.map((child) {
        return AnimatedScale(
          scale: isComplete ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 300),
          child: child.build(context, isComplete: isComplete),
        );
      }).toList(),
    );
  }
}

/// Streaming Card widget
class StreamingCard extends StreamableWidget {
  final StreamableWidget? child;
  final Color? color;

  StreamingCard({this.child, this.color});

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedScale(
      scale: isComplete ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              child?.build(context, isComplete: isComplete) ?? const SizedBox(),
        ),
      ),
    );
  }
}

/// Streaming Button widget
enum StreamingButtonStyle { filled, elevated, outlined, text, dangerous }

class StreamingButton extends StreamableWidget {
  final String text;
  final StreamingButtonStyle buttonStyle;
  final VoidCallback? onTap;

  StreamingButton({
    required this.text,
    this.buttonStyle = StreamingButtonStyle.elevated,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    final buttonChild = Text(text);

    Widget button;
    switch (buttonStyle) {
      case StreamingButtonStyle.filled:
        button = FilledButton(onPressed: onTap, child: buttonChild);
        break;
      case StreamingButtonStyle.outlined:
        button = OutlinedButton(onPressed: onTap, child: buttonChild);
        break;
      case StreamingButtonStyle.text:
        button = TextButton(onPressed: onTap, child: buttonChild);
        break;
      case StreamingButtonStyle.dangerous:
        button = FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: buttonChild,
        );
        break;
      case StreamingButtonStyle.elevated:
        button = ElevatedButton(onPressed: onTap, child: buttonChild);
        break;
    }

    return AnimatedScale(
      scale: isComplete ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: button,
    );
  }
}

/// Streaming TextField widget
enum StreamingTextFieldStyle { outlined, underlined, noOutline }

class StreamingTextField extends StreamableWidget {
  final String? hintText;
  final StreamingTextFieldStyle textFieldStyle;

  StreamingTextField({
    this.hintText,
    this.textFieldStyle = StreamingTextFieldStyle.outlined,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    InputDecoration decoration;

    switch (textFieldStyle) {
      case StreamingTextFieldStyle.underlined:
        decoration = InputDecoration(
          hintText: hintText,
          border: const UnderlineInputBorder(),
        );
        break;
      case StreamingTextFieldStyle.noOutline:
        decoration = InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        );
        break;
      case StreamingTextFieldStyle.outlined:
        decoration = InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        );
        break;
    }

    return AnimatedScale(
      scale: isComplete ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: TextField(decoration: decoration),
    );
  }
}

/// Streaming ListTile widget
class StreamingListTile extends StreamableWidget {
  final String? title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  StreamingListTile({
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedScale(
      scale: isComplete ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: ListTile(
        leading: leadingIcon != null ? Icon(leadingIcon) : null,
        title: title != null ? Text(title!) : null,
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
      ),
    );
  }
}

/// Streaming Container widget
class StreamingContainer extends StreamableWidget {
  final StreamableWidget? child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  StreamingContainer({
    this.child,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedOpacity(
      opacity: isComplete ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        color: color,
        child: child?.build(context, isComplete: isComplete),
      ),
    );
  }
}

/// Streaming Icon widget
class StreamingIcon extends StreamableWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  StreamingIcon({required this.icon, this.color, this.size});

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedScale(
      scale: isComplete ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Icon(icon, color: color, size: size),
    );
  }
}

/// Streaming Divider widget
class StreamingDivider extends StreamableWidget {
  final double? thickness;
  final Color? color;

  StreamingDivider({this.thickness, this.color});

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return AnimatedOpacity(
      opacity: isComplete ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Divider(thickness: thickness, color: color),
    );
  }
}

/// Streaming SizedBox for spacing
class StreamingSizedBox extends StreamableWidget {
  final double? width;
  final double? height;

  StreamingSizedBox({this.width, this.height});

  @override
  Widget build(BuildContext context, {bool isComplete = true}) {
    return SizedBox(width: width, height: height);
  }
}
