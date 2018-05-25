from server.sellar.ttypes import *

# Disc1
def to_openmdao_disc1_inputs(input):
    inputs = {}
    inputs['x'] = input.x
    inputs['z'] = input.z
    return inputs

def to_thrift_disc1_input(inputs):
    input = Disc1Input()
    input.x = inputs['x']
    input.z = inputs['z']
    return inputs

def to_openmdao_disc1_outputs(output):
    outputs = {}
    outputs['y1'] = output.y1
    return outputs

def to_thriftdisc1_output(outputs):
    output = disc1_output()
    output.y1 = outputs['y1']
    return output

# Disc2
def to_openmdao_disc2_input(input):
    inputs = {}
    inputs['z'] = input.z
    return inputs

def to_thrift_disc2_input(inputs):
    input = Disc2Input()
    input.z = inputs['z']
    return inputs

def to_openmdao_disc2_outputs(output):
    outputs = {}
    outputs['y2'] = output.y2
    return outputs

def to_thrift_disc2_output(outputs):
    output = Disc2Output()
    output.y1 = outputs['y2']
    return output

# Functions
def to_openmdao_functions_input(input):
    inputs = {}
    inputs['x'] = input.x
    inputs['z'] = input.z
    inputs['y1'] = input.y1
    inputs['y2'] = input.y2
    return inputs

def to_thrift_functions_input(inputs):
    input = FunctionsInput()
    input.x = inputs['x']
    input.z = inputs['z']
    input.y1 = inputs['y1']
    input.y2 = inputs['y2']
    return inputs

def to_openmdao_functions_outputs(output):
    outputs = {}
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

