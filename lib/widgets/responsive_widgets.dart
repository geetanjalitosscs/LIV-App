import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../theme/liv_theme.dart';

/// Responsive Card Widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveHelper.getPadding(context),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        boxShadow: shadow != null 
          ? [shadow!]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: ResponsiveHelper.getCardElevation(context) * 2,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Padding(
        padding: padding ?? ResponsiveHelper.getPadding(context),
        child: child,
      ),
    );
  }
}

/// Responsive Button Widget
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? ResponsiveHelper.getButtonHeight(context);
    final buttonWidth = width ?? double.infinity;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? LivButtonStyles.primaryButton.copyWith(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? LivTheme.primaryPink,
          ),
          foregroundColor: WidgetStateProperty.all(
            textColor ?? Colors.white,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveHelper.getIconSize(context, mobile: 20),
                height: ResponsiveHelper.getIconSize(context, mobile: 20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: ResponsiveHelper.getIconSize(context, mobile: 18),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getSpacing(context, mobile: 8),
                    ),
                  ],
                  Text(
                    text,
                    style: LivTheme.getButtonText(context),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Responsive Text Widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isHeading1;
  final bool isHeading2;
  final bool isHeading3;
  final bool isBodyLarge;
  final bool isBodyMedium;
  final bool isBodySmall;
  final bool isCaption;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isHeading1 = false,
    this.isHeading2 = false,
    this.isHeading3 = false,
    this.isBodyLarge = false,
    this.isBodyMedium = false,
    this.isBodySmall = false,
    this.isCaption = false,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = style;

    if (textStyle == null) {
      if (isHeading1) {
        textStyle = LivTheme.getHeading1(context);
      } else if (isHeading2) {
        textStyle = LivTheme.getHeading2(context);
      } else if (isHeading3) {
        textStyle = LivTheme.getHeading3(context);
      } else if (isBodyLarge) {
        textStyle = LivTheme.getBodyLarge(context);
      } else if (isBodyMedium) {
        textStyle = LivTheme.getBodyMedium(context);
      } else if (isBodySmall) {
        textStyle = LivTheme.getBodySmall(context);
      } else if (isCaption) {
        textStyle = LivTheme.getCaption(context);
      } else {
        textStyle = LivTheme.getBodyMedium(context);
      }
    }

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive Icon Widget
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;

  const ResponsiveIcon(
    this.icon, {
    super.key,
    this.color,
    this.size,
    this.isSmall = false,
    this.isMedium = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = size ?? ResponsiveHelper.getIconSize(context, mobile: 24);

    if (isSmall) {
      iconSize = ResponsiveHelper.getIconSize(context, mobile: 16);
    } else if (isMedium) {
      iconSize = ResponsiveHelper.getIconSize(context, mobile: 24);
    } else if (isLarge) {
      iconSize = ResponsiveHelper.getIconSize(context, mobile: 32);
    }

    return Icon(
      icon,
      size: iconSize,
      color: color,
    );
  }
}

/// Responsive Container Widget
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final Alignment? alignment;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? ResponsiveHelper.getPadding(context),
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
      ),
      alignment: alignment,
      constraints: constraints ?? ResponsiveHelper.getContainerConstraints(context),
      child: child,
    );
  }
}

/// Responsive Grid Widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.crossAxisCount,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final gridSpacing = spacing ?? ResponsiveHelper.getSpacing(context, mobile: 12);
    final gridRunSpacing = runSpacing ?? ResponsiveHelper.getSpacing(context, mobile: 12);
    final gridCrossAxisCount = crossAxisCount ?? ResponsiveHelper.getGridColumns(context);

    return GridView.count(
      crossAxisCount: gridCrossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? gridSpacing,
      crossAxisSpacing: crossAxisSpacing ?? gridRunSpacing,
      childAspectRatio: childAspectRatio ?? 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive List View Widget
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding ?? ResponsiveHelper.getPadding(context),
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: scrollDirection,
      children: children,
    );
  }
}

/// Responsive Spacing Widget
class ResponsiveSpacing extends StatelessWidget {
  final double? height;
  final double? width;
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;
  final bool isExtraLarge;

  const ResponsiveSpacing({
    super.key,
    this.height,
    this.width,
    this.isSmall = false,
    this.isMedium = false,
    this.isLarge = false,
    this.isExtraLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    double spacingHeight = height ?? ResponsiveHelper.getSpacing(context, mobile: 16);
    double spacingWidth = width ?? 0;

    if (isSmall) {
      spacingHeight = ResponsiveHelper.getSpacing(context, mobile: 8);
    } else if (isMedium) {
      spacingHeight = ResponsiveHelper.getSpacing(context, mobile: 16);
    } else if (isLarge) {
      spacingHeight = ResponsiveHelper.getSpacing(context, mobile: 24);
    } else if (isExtraLarge) {
      spacingHeight = ResponsiveHelper.getSpacing(context, mobile: 32);
    }

    return SizedBox(
      height: spacingHeight,
      width: spacingWidth,
    );
  }
}

/// Responsive Avatar Widget
class ResponsiveAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? radius;
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;

  const ResponsiveAvatar({
    super.key,
    this.imageUrl,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.isSmall = false,
    this.isMedium = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    double avatarRadius = radius ?? ResponsiveHelper.getAvatarSize(context) / 2;

    if (isSmall) {
      avatarRadius = ResponsiveHelper.getAvatarSize(context) * 0.6 / 2;
    } else if (isMedium) {
      avatarRadius = ResponsiveHelper.getAvatarSize(context) / 2;
    } else if (isLarge) {
      avatarRadius = ResponsiveHelper.getAvatarSize(context) * 1.4 / 2;
    }

    return CircleAvatar(
      radius: avatarRadius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: icon != null ? Icon(icon) : null,
    );
  }
}

/// Responsive Logo Widget
class ResponsiveLogo extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final Color? color;
  final double? size;
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;

  const ResponsiveLogo({
    super.key,
    this.imageUrl,
    this.icon,
    this.color,
    this.size,
    this.isSmall = false,
    this.isMedium = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    double logoSize = size ?? ResponsiveHelper.getLogoSize(context);

    if (isSmall) {
      logoSize = ResponsiveHelper.getLogoSize(context) * 0.7;
    } else if (isMedium) {
      logoSize = ResponsiveHelper.getLogoSize(context);
    } else if (isLarge) {
      logoSize = ResponsiveHelper.getLogoSize(context) * 1.3;
    }

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: LivTheme.buttonGradient,
        ),
      ),
      child: icon != null
          ? Icon(
              icon,
              size: logoSize * 0.6,
              color: Colors.white,
            )
          : imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
    );
  }
}

