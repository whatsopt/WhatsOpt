# -*- coding: utf-8 -*-
"""
  ssbj_conversions.py generated by WhatsOpt. 
"""
import numpy as np
from .ssbj.ttypes import *


# Structure 
def to_openmdao_structure_inputs(ins, inputs={}):
    
    inputs['L'] = np.array(ins.L)
    inputs['WE'] = np.array(ins.WE)
    inputs['x_str'] = np.array(ins.x_str)
    inputs['z'] = np.array(ins.z)
    return inputs

def to_thrift_structure_input(inputs):
    ins = StructureInput()
    
    
    ins.L = inputs['L'].tolist()
    
    
    ins.WE = inputs['WE'].tolist()
    
    
    ins.x_str = inputs['x_str'].tolist()
    
    
    ins.z = inputs['z'].tolist()
    
    return ins

def to_openmdao_structure_outputs(output, outputs={}):
    
    outputs['Theta'] = np.array(output.Theta)
    outputs['sigma'] = np.array(output.sigma)
    outputs['WT'] = np.array(output.WT)
    outputs['WF'] = np.array(output.WF)
    return outputs

def to_thrift_structure_output(outputs):
    output = StructureOutput()
    
    
    output.Theta = outputs['Theta'].tolist()
    
    
    output.sigma = outputs['sigma'].tolist()
    
    
    output.WT = outputs['WT'].tolist()
    
    
    output.WF = outputs['WF'].tolist()
    
    return output

# Aerodynamics 
def to_openmdao_aerodynamics_inputs(ins, inputs={}):
    
    inputs['ESF'] = np.array(ins.ESF)
    inputs['Theta'] = np.array(ins.Theta)
    inputs['WT'] = np.array(ins.WT)
    inputs['x_aer'] = np.array(ins.x_aer)
    inputs['z'] = np.array(ins.z)
    return inputs

def to_thrift_aerodynamics_input(inputs):
    ins = AerodynamicsInput()
    
    
    ins.ESF = inputs['ESF'].tolist()
    
    
    ins.Theta = inputs['Theta'].tolist()
    
    
    ins.WT = inputs['WT'].tolist()
    
    
    ins.x_aer = inputs['x_aer'].tolist()
    
    
    ins.z = inputs['z'].tolist()
    
    return ins

def to_openmdao_aerodynamics_outputs(output, outputs={}):
    
    outputs['dpdx'] = np.array(output.dpdx)
    outputs['D'] = np.array(output.D)
    outputs['L'] = np.array(output.L)
    outputs['fin'] = np.array(output.fin)
    return outputs

def to_thrift_aerodynamics_output(outputs):
    output = AerodynamicsOutput()
    
    
    output.dpdx = outputs['dpdx'].tolist()
    
    
    output.D = outputs['D'].tolist()
    
    
    output.L = outputs['L'].tolist()
    
    
    output.fin = outputs['fin'].tolist()
    
    return output

# Propulsion 
def to_openmdao_propulsion_inputs(ins, inputs={}):
    
    inputs['D'] = np.array(ins.D)
    inputs['x_pro'] = np.array(ins.x_pro)
    inputs['z'] = np.array(ins.z)
    return inputs

def to_thrift_propulsion_input(inputs):
    ins = PropulsionInput()
    
    
    ins.D = inputs['D'].tolist()
    
    
    ins.x_pro = inputs['x_pro'].tolist()
    
    
    ins.z = inputs['z'].tolist()
    
    return ins

def to_openmdao_propulsion_outputs(output, outputs={}):
    
    outputs['DT'] = np.array(output.DT)
    outputs['ESF'] = np.array(output.ESF)
    outputs['Temp'] = np.array(output.Temp)
    outputs['WE'] = np.array(output.WE)
    outputs['SFC'] = np.array(output.SFC)
    return outputs

def to_thrift_propulsion_output(outputs):
    output = PropulsionOutput()
    
    
    output.DT = outputs['DT'].tolist()
    
    
    output.ESF = outputs['ESF'].tolist()
    
    
    output.Temp = outputs['Temp'].tolist()
    
    
    output.WE = outputs['WE'].tolist()
    
    
    output.SFC = outputs['SFC'].tolist()
    
    return output

# Performance 
def to_openmdao_performance_inputs(ins, inputs={}):
    
    inputs['SFC'] = np.array(ins.SFC)
    inputs['WF'] = np.array(ins.WF)
    inputs['WT'] = np.array(ins.WT)
    inputs['fin'] = np.array(ins.fin)
    inputs['z'] = np.array(ins.z)
    return inputs

def to_thrift_performance_input(inputs):
    ins = PerformanceInput()
    
    
    ins.SFC = inputs['SFC'].tolist()
    
    
    ins.WF = inputs['WF'].tolist()
    
    
    ins.WT = inputs['WT'].tolist()
    
    
    ins.fin = inputs['fin'].tolist()
    
    
    ins.z = inputs['z'].tolist()
    
    return ins

def to_openmdao_performance_outputs(output, outputs={}):
    
    outputs['R'] = np.array(output.R)
    return outputs

def to_thrift_performance_output(outputs):
    output = PerformanceOutput()
    
    
    output.R = float(outputs['R'])
    
    return output

# Constraints 
def to_openmdao_constraints_inputs(ins, inputs={}):
    
    inputs['DT'] = np.array(ins.DT)
    inputs['ESF'] = np.array(ins.ESF)
    inputs['Temp'] = np.array(ins.Temp)
    inputs['Theta'] = np.array(ins.Theta)
    inputs['dpdx'] = np.array(ins.dpdx)
    inputs['sigma'] = np.array(ins.sigma)
    return inputs

def to_thrift_constraints_input(inputs):
    ins = ConstraintsInput()
    
    
    ins.DT = inputs['DT'].tolist()
    
    
    ins.ESF = inputs['ESF'].tolist()
    
    
    ins.Temp = inputs['Temp'].tolist()
    
    
    ins.Theta = inputs['Theta'].tolist()
    
    
    ins.dpdx = inputs['dpdx'].tolist()
    
    
    ins.sigma = inputs['sigma'].tolist()
    
    return ins

def to_openmdao_constraints_outputs(output, outputs={}):
    
    outputs['con1_esf'] = np.array(output.con1_esf)
    outputs['con2_esf'] = np.array(output.con2_esf)
    outputs['con_dpdx'] = np.array(output.con_dpdx)
    outputs['con_dt'] = np.array(output.con_dt)
    outputs['con_sigma1'] = np.array(output.con_sigma1)
    outputs['con_sigma2'] = np.array(output.con_sigma2)
    outputs['con_sigma3'] = np.array(output.con_sigma3)
    outputs['con_sigma4'] = np.array(output.con_sigma4)
    outputs['con_sigma5'] = np.array(output.con_sigma5)
    outputs['con_temp'] = np.array(output.con_temp)
    outputs['con_theta_low'] = np.array(output.con_theta_low)
    outputs['con_theta_up'] = np.array(output.con_theta_up)
    return outputs

def to_thrift_constraints_output(outputs):
    output = ConstraintsOutput()
    
    
    output.con1_esf = float(outputs['con1_esf'])
    
    
    output.con2_esf = float(outputs['con2_esf'])
    
    
    output.con_dpdx = float(outputs['con_dpdx'])
    
    
    output.con_dt = float(outputs['con_dt'])
    
    
    output.con_sigma1 = float(outputs['con_sigma1'])
    
    
    output.con_sigma2 = float(outputs['con_sigma2'])
    
    
    output.con_sigma3 = float(outputs['con_sigma3'])
    
    
    output.con_sigma4 = float(outputs['con_sigma4'])
    
    
    output.con_sigma5 = float(outputs['con_sigma5'])
    
    
    output.con_temp = float(outputs['con_temp'])
    
    
    output.con_theta_low = float(outputs['con_theta_low'])
    
    
    output.con_theta_up = float(outputs['con_theta_up'])
    
    return output
