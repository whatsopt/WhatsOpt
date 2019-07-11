namespace py whatsopt.surrogate_server
namespace rb WhatsOpt.SurrogateServer
 
typedef double Float
typedef list<Float> Vector
typedef list<Vector> Matrix

enum SurrogateKind {
  KRIGING,
  KPLS,
  KPLSK,
  LS,
  QP
}

exception SurrogateException {
  1: string msg
}

service SurrogateStore {

  void ping();
  oneway void shutdown();

  void create_surrogate(1: string surrogate_id,
                        2: SurrogateKind kind, 
                        3: Matrix xt, 
                        4: Vector yt) throws (1: SurrogateException exc);

  Vector predict_values(1: string surrogate_id, 
                        2: Matrix x) throws (1: SurrogateException exc);

  void destroy_surrogate(1: string surrogate_id);
  
}