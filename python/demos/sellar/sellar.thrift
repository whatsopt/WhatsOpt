namespace py sellar

typedef double Float
typedef i32 Integer
typedef list<Float> Vector
typedef list<Vector> Matrix
typedef list<Matrix> Cube

struct Disc1Input {
    1: Float  x
    2: Vector z   
    3: Float y2   
}

struct Disc1Output {
    1: Float y1
}

struct Disc2Input {
    1: Vector z   
    2: Float y1
}

struct Disc2Output {
    1: Float y2
}

struct FunctionsInput {
    1: Float  x
    2: Vector z   
    3: Float y1
    4: Float y2
}

struct FunctionsOutput {
    1: Float obj
    2: Float g1
    3: Float g2
}

service Sellar {
    Disc1Output compute_disc1(1:Disc1Input ins)
    Disc2Output compute_disc2(1:Disc2Input ins)
    FunctionsOutput compute_functions(1:FunctionsInput ins)
}