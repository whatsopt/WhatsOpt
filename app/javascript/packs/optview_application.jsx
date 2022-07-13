import React, { useState} from 'react'
import ReactDOM from 'react-dom'
import OptView from 'optview';


document.addEventListener('DOMContentLoaded', () => {
  const node = document.getElementById('optimization_plot')
  const optimization_data = JSON.parse(node.getAttribute('optimization_data'))
  ReactDOM.render(
    <OptView optim={optimization_data}/>,
    document.getElementById("optimization_plot"),
  )
})