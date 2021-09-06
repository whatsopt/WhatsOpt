import consumer from './consumer';

const AppearanceChannel = consumer.subscriptions.create('AppearanceChannel', {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log('COUCOU');
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data);
  },
});

export default AppearanceChannel;
