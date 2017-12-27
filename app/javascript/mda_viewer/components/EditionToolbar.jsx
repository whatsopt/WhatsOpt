import React from 'react';
import axios from 'axios';

let token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'
axios.defaults.headers.common['Authorization'] = 'Token '+API_KEY
let relative_url_root = document.getElementsByName('relative-url-root')[0].getAttribute('content')
//axios.defaults.baseURL = 'http://endymion:3000'

//prepend relative_url_root
var url = function (path) {
    return relative_url_root+path;
}

class EditionToolbar extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
    };
  }

  componentDidMount() {
  }

  render() {
    return (
      <div>
        <div className="btn-toolbar" role="toolbar">   
          <div className="btn-group mr-2" role="group"> 
            <a className="btn btn-primary" href="#">Save</a>
          </div>
        </div>  
      </div>
    );
  }
}

export default EditionToolbar;