import "dart:math";

// 补充的 java 方法
double hypot(double dx, double dy){
  return sqrt(dx * dx + dy * dy);
}

bool equalsWithTolerance(double x1, double x2, double tolerance)
{
  return (x1 - x2).abs() <= tolerance;
}
