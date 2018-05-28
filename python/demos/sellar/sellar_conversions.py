from server.sellar.ttypes import *

# Disc1
def to_openmdao_disc1_inputs(ins, inputs={}):
    inputs['x'] = ins.x
    inputs['z'] = ins.z
    inputs['y2'] = ins.y2
    return inputs

def to_thrift_disc1_input(inputs):
    ins = Disc1Input()
    ins.x = inputs['x']
    ins.z = inputs['z']
    ins.y2 = inputs['y2']
    return ins

def to_openmdao_disc1_outputs(output, outputs={}):
    outputs['y1'] = output.y1
    return outputs

def to_thrift_disc1_output(outputs):
    output = Disc1Output()
    output.y1 = outputs['y1']
    return output

# Disc2
def to_openmdao_disc2_inputs(ins, inputs={}):
    inputs = {}
    inputs['z'] = ins.z
    inputs['y1'] = ins.y1
    return inputs

def to_thrift_disc2_input(inputs):
    ins = Disc2Input()
    ins.z = inputs['z']
    ins.y1 = inputs['y1']
    return ins

def to_openmdao_disc2_outputs(output, outputs={}):
    outputs['y2'] = output.y2
    return outputs

def to_thrift_disc2_output(outputs):
    output = Disc2Output()
    output.y2 = outputs['y2']
    return output

# Functions
def to_openmdao_functions_inputs(ins, inputs={}):
    inputs = {}
    inputs['x'] = ins.x
    inputs['z'] = ins.z
    inputs['y1'] = ins.y1
    inputs['y2'] = ins.y2
    return inputs

def to_thrift_functions_input(inputs):
    ins = FunctionsInput()
    ins.x = inputs['x']
    ins.z = inputs['z']
    ins.y1 = inputs['y1']
    ins.y2 = inputs['y2']
    return ins

def to_openmdao_functions_outputs(output, outputs={}):
    outputs['obj'] = output.obj
    outputs['g1'] = output.g1
    outputs['g2'] = output.g2
    return outputs

def to_thrift_functions_output(outputs):
    output = FunctionsOutput()
    output.obj = outputs['obj']
    output.g1 = outputs['g1']    
    output.g2 = outputs['g2']
    return output

