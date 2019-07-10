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

service SurrogateStore {

  void ping();
  oneway void shutdown();

  void create_surrogate(1: string surrogate_id,
                        2: SurrogateKind kind, 
                        3: Matrix xt, 
                        4: Vector yt);

  Vector predict_values(1: string surrogate_id, 
                        2: Matrix x);

  void destroy_surrogate(1: string surrogate_id);
  
}