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

enum SurrogateKind {
  SMT_KRIGING,
  SMT_KPLS,
  SMT_KPLSK,
  SMT_LS,
  SMT_QP,
  OPENTURNS_PCE
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

service Administration {
  void ping();

  oneway void shutdown();
}

service SurrogateStore {
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


enum OptimizerKind {
  SEGOMOE,
  SEGMOOMOE
}

struct OptimizerResult {
  1: Integer status,
  2: Vector x_suggested,
  3: optional Matrix x_best, 
  4: optional Matrix y_best 
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

service OptimizerStore {

  void create_optimizer(1: string optimizer_id,
                        2: OptimizerKind kind,
                        3: Matrix xlimits, 
                        4: ConstraintSpecs cstr_specs, 
                        5: Options options) throws (1: OptimizerException exc);

  void create_mixint_optimizer(1: string optimizer_id,
                               2: OptimizerKind kind,
                               3: Xtypes xtypes, 
                               4: Integer n_obj,
                               5: ConstraintSpecs cstr_specs, 
                               6: Options options) throws (1: OptimizerException exc);

  OptimizerResult ask(1: string optimizer_id, 2: bool with_best) throws (1: OptimizerException exc);

  void tell(1: string optimizer_id, 2: Matrix x, 3: Matrix y) throws (1: OptimizerException exc);

  void destroy_optimizer(1: string optimizer_id);
}



enum Thresholding {
  ZERO,
  COND,
  IND,
}

struct HsicAnalysis {
  1: Vector indices,
  2: Vector r2,
  3: Vector pvperm,
  4: Vector pvas
}

service SensitivityAnalyser {

  HsicAnalysis compute_hsic(1: Thresholding thresholding_type
                            2: Matrix xdoe, 
                            3: Matrix ydoe, 
                            4: Float quantile
                            5: Float g_threshold);

}