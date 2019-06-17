namespace py surrogate_server

typedef double Float
typedef list<Float> Vector
typedef list<Vector> Matrix

service Surrogate {

  void create_analysis_surrogate(1: string surrogate_id,
                                 2: string analysis_id, 
                                 3: Matrix x, 
                                 4: list<string> ynames,
                                 5: Vector y);

  Vector predict_values(1: string analysis_id, 
                        2: string yname, 
                        3: Matrix x);

}