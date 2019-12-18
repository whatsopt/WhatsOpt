namespace py whatsopt.surrogate_server
namespace rb WhatsOpt.SurrogateServer
 
typedef double Float
typedef list<Float> Vector
typedef list<Vector> Matrix

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

struct SurrogateQualification {
  1: Float r2,
  2: Vector yp
}

service SurrogateStore {

  void ping();
  oneway void shutdown();

  void create_surrogate(1: string surrogate_id,
                        2: SurrogateKind kind, 
                        3: Matrix xt, 
                        4: Vector yt) throws (1: SurrogateException exc);

  void copy_surrogate(1: string src_id, 
                      2: string dst_id) throws (1: SurrogateException exc);

  SurrogateQualification qualify(1: string surrogate_id,
                                 2: Matrix xv, 
                                 3: Vector yv) throws (1: SurrogateException exc);

  Vector predict_values(1: string surrogate_id, 
                        2: Matrix x) throws (1: SurrogateException exc);

  void destroy_surrogate(1: string surrogate_id);
  
}