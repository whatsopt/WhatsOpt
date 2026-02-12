namespace py whatsopt_server.services
namespace rb WhatsOpt.Services
 
typedef i64 Integer
typedef double Float
typedef list<Float> Vector
typedef list<Vector> Matrix

typedef string OptionName;
union OptionValue {
  1: Integer integer,
  2: Float number,
  3: Vector vector,
  4: Matrix matrix,
  5: string str,
  6: bool boolean
}
typedef map<OptionName, OptionValue> Options;
typedef map<OptionName, double> Kwargs;

struct Distribution {
  1: string name,
  2: Kwargs kwargs
}
typedef list<Distribution> Distributions;

service Administration {
  void ping();

  oneway void shutdown();
}


enum ConstraintType {
  LESS,
  EQUAL,
  GREATER
}

struct ConstraintSpec {
  1: ConstraintType type,
  2: Float bound
}
typedef list<ConstraintSpec> ConstraintSpecs;

enum Type {
  FLOAT,
  INT,
  ORD,
  ENUM
}
struct Flimits {
  1: Float lower,
  2: Float upper 
}
struct Ilimits {
  1: Integer lower,
  2: Integer upper 
}
typedef list<Float> Olimits
typedef list<string> Elimits
union Xlimits {
  1: Flimits flimits,
  2: Ilimits ilimits,
  3: Olimits olimits,
  4: Elimits elimits
}
struct Xtype {
  1: Type type,
  2: Xlimits limits
}
typedef list<Xtype> Xtypes;

