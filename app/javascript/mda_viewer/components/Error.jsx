import React from 'react';

class Error extends React.Component {
  render() {
    return (<div className="alert alert-warning" role="alert">
              <a href="#" data-dismiss="alert" className="close">×</a>
              {this.props.msg}
            </div>);
  }
}

export default Error;
