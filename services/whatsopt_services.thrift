namespace py whatsopt_server.services
namespace rb WhatsOpt.Services
 
typedef i64 Integer
typedef double Float
typedef list<Float> Vector
typedef list<Vector> Matrix

typedef string OptionName;
struct OptionValue {
  1: optional Integer integer,
  2: optional Float number,
  3: optional Vector vector,
  4: optional Matrix matrix,
  5: optional string str
}
typedef map<OptionName, OptionValue> Options;
typedef map<OptionName, double> Kwargs;

enum SurrogateKind {
  SMT_KRIGING,
  SMT_KPLS,
  SMT_KPLSK,
  SMT_LS,
  SMT_QP,
  OPENTURNS_PCE
}

enum OptimizerKind {
  SEGOMOE,
}

exception SurrogateException {
  1: string msg
}

exception OptimizerException {
  1: string msg
}

struct SurrogateQualification {
  1: Float r2,
  2: Vector yp
}

struct SobolIndices {
  1: Vector S1,
  2: Vector ST
}

struct Distribution {
  1: string name,
  2: Kwargs kwargs
}
typedef list<Distribution> Distributions;

service SurrogateStore {

  void ping();
  oneway void shutdown();

  void create_surrogate(1: string surrogate_id,
                        2: SurrogateKind kind, 
                        3: Matrix xt, 
                        4: Vector yt,
                        5: Options options,
                        6: Distributions uncertainties) throws (1: SurrogateException exc);

  void copy_surrogate(1: string src_id, 
                      2: string dst_id) throws (1: SurrogateException exc);

  SurrogateQualification qualify(1: string surrogate_id,
                                 2: Matrix xv, 
                                 3: Vector yv) throws (1: SurrogateException exc);

  Vector predict_values(1: string surrogate_id, 
                        2: Matrix x) throws (1: SurrogateException exc);

  void destroy_surrogate(1: string surrogate_id);

  SobolIndices get_sobol_pce_sensitivity_analysis(1: string surrogate_id);
}


service OptimizerStore {

  void ping();
  void create_optimizer(1: string optimizer_id,
                        2: OptimizerKind kind,
                        3: Options options) throws (1: OptimizerException exc);

  Float ask(1: string optimizer_id) throws (1: OptimizerException exc);

  void tell(1: string optimizer_id, 2: Matrix x, 3: Matrix y) throws (1: OptimizerException exc);

  void destroy_optimizer(1: string surrogate_id);
}

