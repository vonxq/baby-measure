const app = getApp()

Page({
  data: {
    userInfo: null,
    nickName: '',
    avatarUrl: ''
  },

  onLoad() {
    this.loadUserInfo()
  },

  loadUserInfo() {
    const userInfo = app.globalData.userInfo
    if (userInfo) {
      this.setData({
        userInfo,
        nickName: userInfo.nickName || '',
        avatarUrl: userInfo.avatarUrl || ''
      })
    }
  },

  chooseAvatar() {
    wx.chooseImage({
      count: 1,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: (res) => {
        const tempFilePath = res.tempFilePaths[0]
        this.setData({
          avatarUrl: tempFilePath
        })
      }
    })
  },

  inputNickName(e) {
    this.setData({
      nickName: e.detail.value
    })
  },

  saveUserInfo() {
    if (!this.data.nickName.trim()) {
      wx.showToast({
        title: '请输入昵称',
        icon: 'none'
      })
      return
    }

    const userInfo = {
      ...this.data.userInfo,
      nickName: this.data.nickName,
      avatarUrl: this.data.avatarUrl
    }

    // 更新全局数据
    app.globalData.userInfo = userInfo
    wx.setStorageSync('userInfo', userInfo)

    wx.showToast({
      title: '保存成功',
      icon: 'success'
    })

    setTimeout(() => {
      wx.navigateBack()
    }, 1500)
  }
}) 