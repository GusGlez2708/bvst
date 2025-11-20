import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CollisionParticle extends PositionComponent {
  final Color color;
  final double lifetime;
  double _elapsed = 0.0;
  late List<_Particle> particles;

  CollisionParticle({
    required Vector2 position,
    this.color = const Color(0xFFFFAA00),
    this.lifetime = 0.5,
    int particleCount = 8,
  }) : super(position: position, size: Vector2.zero()) {
    // Create particles spreading out in different directions
    particles = List.generate(particleCount, (index) {
      final angle = (index / particleCount) * 2 * pi;
      final speed = 100.0 + (index % 3) * 50.0; // Varied speeds
      return _Particle(
        velocity: Vector2(speed * cos(angle), speed * sin(angle)),
        size: 4.0 + (index % 2) * 2.0,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= lifetime) {
      removeFromParent();
      return;
    }

    // Update particle positions
    for (var particle in particles) {
      particle.position.add(particle.velocity * dt);
      // Apply some gravity/deceleration
      particle.velocity.y += 200 * dt;
      particle.velocity.scale(0.98);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = color.withOpacity(1.0 - (_elapsed / lifetime));

    for (var particle in particles) {
      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size,
        paint,
      );
    }
  }
}

class _Particle {
  Vector2 position = Vector2.zero();
  Vector2 velocity;
  double size;

  _Particle({required this.velocity, required this.size});
}
