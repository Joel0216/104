import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'model/product.dart';

const double _kFlingVelocity = 2.0;

class Backdrop extends StatefulWidget {
  final Category currentCategory;
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;
  // Agregamos callbacks para los botones de búsqueda y filtro
  final VoidCallback? onSearchPressed;
  final VoidCallback? onFilterPressed;


  const Backdrop({
    required this.currentCategory,
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    this.onSearchPressed,
    this.onFilterPressed,
    Key? key,
  }) : super(key: key);

  @override
  _BackdropState createState() => _BackdropState();
}

class _FrontLayer extends StatelessWidget {
  const _FrontLayer({
    Key? key,
    this.onTap,
    required this.child,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final void Function() onPress;
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key? key,
    required Animation<double> listenable,
    required this.onPress,
    required this.frontTitle,
    required this.backTitle,
  }) : _listenable = listenable,
        super(key: key, listenable: listenable);

  final Animation<double> _listenable;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = _listenable;
    final ThemeData theme = Theme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.headlineMedium!,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Row(children: <Widget>[
        // Ícono de menú animado
        SizedBox(
          width: 72.0,
          child: IconButton(
            padding: const EdgeInsets.only(right: 8.0),
            onPressed: this.onPress,
            icon: Stack(children: <Widget>[
              // Ícono de menú (3 palitos)
              Opacity(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0),
                ).value,
                child: const Icon(Icons.menu), // Icono de menú estándar (Icons.menu)
              ),
              // Ícono de cerrar (X) (solo se muestra cuando el menú está a mitad o totalmente abierto)
              Opacity(
                opacity: CurvedAnimation(
                  parent: ReverseAnimation(animation),
                  curve: const Interval(0.5, 1.0),
                ).value,
                child: const Icon(Icons.close),
              )
            ]),
          ),
        ),
        // Título animado
        Stack(
          children: <Widget>[
            // Título de la capa de atrás ("MENU")
            Opacity(
              opacity: CurvedAnimation(
                parent: ReverseAnimation(animation),
                curve: const Interval(0.5, 1.0),
              ).value,
              child: FractionalTranslation(
                translation: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0.5, 0.0),
                ).evaluate(animation),
                child: backTitle,
              ),
            ),
            // Título de la capa frontal (Categoría actual)
            Opacity(
              opacity: CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1.0),
              ).value,
              child: FractionalTranslation(
                translation: Tween<Offset>(
                  begin: const Offset(-0.25, 0.0),
                  end: Offset.zero,
                ).evaluate(animation),
                child: frontTitle,
              ),
            ),
          ],
        )
      ]),
    );
  }
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Inicia con la capa frontal visible (cerrada)
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(Backdrop old) {
    super.didUpdateWidget(old);
    // Cierra el menú si la categoría ha cambiado
    if (widget.currentCategory != old.currentCategory) {
      _toggleBackdropLayerVisibility();
    } else if (!_frontLayerVisible) {
      // Si el menú está abierto pero no hay cambios, se cierra.
      _controller.fling(velocity: _kFlingVelocity);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    _controller.fling(
        velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, layerTop, 0.0, layerTop - layerSize.height),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    return Stack(
      key: _backdropKey,
      children: <Widget>[
        // Capa de Atrás (Menú)
        ExcludeSemantics(
          child: widget.backLayer,
          excluding: _frontLayerVisible,
        ),
        // Capa Frontal (Productos)
        PositionedTransition(
          rect: layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            child: widget.frontLayer,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      elevation: 0.0,
      titleSpacing: 0.0,
      backgroundColor: kShrinePink100, 
      foregroundColor: kShrineBrown900,
      systemOverlayStyle: SystemUiOverlayStyle.dark, 
      
      // Ícono de menú principal (los "3 palitos" / "X")
      title: _BackdropTitle(
        listenable: _controller.view,
        onPress: _toggleBackdropLayerVisibility,
        frontTitle: widget.frontTitle,
        backTitle: widget.backTitle,
      ),
      actions: <Widget>[
        // Ícono de búsqueda (Lupa)
        IconButton(
          icon: const Icon(Icons.search, semanticLabel: 'search'),
          // LLAMA A LA FUNCIÓN DE BÚSQUEDA DEL HOME.DART
          onPressed: widget.onSearchPressed, 
        ),
        // Ícono de filtros
        IconButton(
          icon: const Icon(Icons.tune, semanticLabel: 'filter'),
          // LLAMA A LA FUNCIÓN DE FILTROS DEL HOME.DART
          onPressed: widget.onFilterPressed, 
        ),
      ],
    );
    
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(builder: _buildStack),
    );
  }
}