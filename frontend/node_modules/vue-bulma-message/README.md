# Message

Message component for Vue Bulma.


## Installation

```
$ npm install vue-bulma-message --save
```


## Examples

```vue
<template>
  <div>
    <message :title="'Normal'" :direction="'Down'" :message="'Lorem ipsum dolor sit amet, consectetur adipiscing elit lorem ipsum dolor sit amet, consectetur adipiscing elit'" :duration="0"></message>
    <button class="button" @click="openMessageWithType('')">Normal</button>
    <button class="button is-primary" @click="openMessageWithType('primary')">Primary</button>
    <button class="button is-info" @click="openMessageWithType('info')">Info</button>
    <button class="button is-success" @click="openMessageWithType('success')">Success</button>
    <button class="button is-warning" @click="openMessageWithType('warning')">Warning</button>
    <button class="button is-danger" @click="openMessageWithType('danger')">Danger</button>
  </div>
</template>

<script>
import Vue from 'vue'
import Message from 'vue-bulma-message'

const MessageComponent = Vue.extend(Message)

const openMessage = (propsData = {
  title: '',
  message: '',
  type: '',
  direction: '',
  duration: 1500,
  container: '.messages'
}) => {
  return new MessageComponent({
    el: document.createElement('div'),
    propsData
  })
}

export default {
  components: {
    Message
  },

  mounted () {
    openMessage({
      message: 'Success lorem ipsum dolor sit amet, consectetur adipiscing elit lorem ipsum dolor sit amet, consectetur adipiscing elit',
      type: 'success',
      duration: 0,
      showCloseButton: true
    })
  },

  methods: {
    openMessageWithType (type) {
      openMessage({
        title: 'This is a title',
        message: 'This is the message.',
        type: type
      })
    }
  }
}
</script>
```


## Badges

![](https://img.shields.io/badge/license-MIT-blue.svg)
![](https://img.shields.io/badge/status-stable-green.svg)

---

> [fundon.me](https://fundon.me) &nbsp;&middot;&nbsp;
> GitHub [@fundon](https://github.com/fundon) &nbsp;&middot;&nbsp;
> Twitter [@_fundon](https://twitter.com/_fundon)

