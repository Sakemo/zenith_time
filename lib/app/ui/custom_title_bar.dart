import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/core/dev/data_seeder.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zenith_time/app/theme/app_theme.dart';

class CustomTitleBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomTitleBar({super.key});

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();

  @override
  Size get preferredSize => const Size.fromHeight(32.0);
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    // checa estado inicial da janela
    windowManager.isMaximized().then((v) {
      setState(() => _isMaximized = v);
    });
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // Listener para mudanças externas (ex.: atalhos ou gestor de janelas)
  @override
  void onWindowMaximize() {
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    // paleta inspirada no moodboard: fundo escuro + acento azul (ícones brancos)
    final bgColor = AppTheme.adwaitaHeaderBar;
    const iconColor = AppTheme.adwaitaTextColor;
    const closeHoverRed = AppTheme.adwaitaBlue;
    const accentBlue = AppTheme.adwaitaBlue;

    return DragToMoveArea(
      child: Container(
        height: widget.preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: bgColor,
        child: Row(
          children: [
            if (kDebugMode)
              IconButton(
                icon: const Icon(
                  Icons.bug_report,
                  color: AppTheme.adwaitaTextColor,
                  size: 16,
                ),
                tooltip: 'Seed Mock Data',
                onPressed: () async {
                  // Pega as instâncias dos serviços
                  final projectService = context.read<ProjectService>();
                  final taskService = context.read<TaskService>();
                  final timeEntryService = context.read<TimeEntryService>();

                  // Cria e executa o seeder
                  final seeder = DataSeeder(
                    projectService,
                    taskService,
                    timeEntryService,
                  );
                  await seeder.seedDatabase();

                  // Mostra um feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados de teste gerados com sucesso!'),
                    ),
                  );
                },
              ),
            // título centralizado visualmente à esquerda (ocupar espaço)
            const Expanded(
              child: Center(
                child: Text(
                  'Zenith Time',
                  style: TextStyle(
                    color: AppTheme.adwaitaTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            // Botões customizados (minimizar, maximizar, fechar)
            _TitleBarButton(
              tooltip: '',
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
              iconColor: iconColor,
              hoverDecoration: BoxDecoration(
                color: accentBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: accentBlue.withOpacity(0.18),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _TitleBarButton(
              tooltip: _isMaximized ? '' : '',
              icon: _isMaximized ? Icons.crop_square : Icons.crop_din,
              onPressed: () async {
                final maximized = await windowManager.isMaximized();
                if (maximized) {
                  await windowManager.unmaximize();
                  setState(() => _isMaximized = false);
                } else {
                  await windowManager.maximize();
                  setState(() => _isMaximized = true);
                }
              },
              iconColor: iconColor,
              hoverDecoration: BoxDecoration(
                color: accentBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: accentBlue.withOpacity(0.18),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _TitleBarButton(
              tooltip: '',
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              iconColor: iconColor,
              // fechar usa hover com leve vermelho para sinalizar perigo, mantendo estética
              hoverDecoration: BoxDecoration(
                color: closeHoverRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: closeHoverRed.withOpacity(0.18),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão reutilizável para a titlebar com efeito hover animado.
/// Mantém o ícone branco e aplica uma decoração configurável ao passar o mouse.
class _TitleBarButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final BoxDecoration hoverDecoration;
  final double size;

  const _TitleBarButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.hoverDecoration,
    this.size = 32,
  });

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // base decoration (transparente) e hover animation
    final baseDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          verticalOffset: 10,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: widget.size + 8,
            height: widget.size,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: _hover ? widget.hoverDecoration : baseDecoration,
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.iconColor.withOpacity(_pressed ? 0.85 : 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
