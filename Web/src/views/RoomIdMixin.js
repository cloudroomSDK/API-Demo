import Cookies from 'js-cookie'
const lastRoomId = 'LastRoomId'

export default {
  data() {
    return {
      roomId: ''
    }
  },
  created() {
    this.roomId = Cookies.get(lastRoomId) || '' // 读取并填充以前的房间号
  },
  methods: {
    // 子组件更新了房间号
    updateRoomId(roomId) {
      this.roomId = roomId
    }
  }
}
