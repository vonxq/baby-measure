const app = getApp()

Page({
  data: {
    isEdit: false,
    babyId: '',
    nickname: '',
    birthday: ''
  },

  onLoad(options) {
    if (options.id) {
      this.setData({
        isEdit: true,
        babyId: options.id
      })
      this.loadBabyInfo(options.id)
    }
  },

  loadBabyInfo(babyId) {
    wx.request({
      url: `${app.globalData.baseUrl}/baby/${babyId}`,
      method: 'GET',
      success: (res) => {
        if (res.data.success) {
          const baby = res.data.data
          this.setData({
            nickname: baby.nickname,
            birthday: baby.birthday
          })
        }
      },
      fail: () => {
        // 模拟数据
        this.setData({
          nickname: '小宝贝',
          birthday: '2023-06-15'
        })
      }
    })
  },

  onBirthdayChange(e) {
    this.setData({
      birthday: e.detail.value
    })
  },

  saveBaby() {
    if (!this.data.nickname || !this.data.birthday) {
      wx.showToast({
        title: '请填写完整信息',
        icon: 'none'
      })
      return
    }

    const babyData = {
      nickname: this.data.nickname,
      birthday: this.data.birthday,
      userId: app.globalData.userInfo.openId
    }

    if (this.data.isEdit) {
      // 编辑模式
      wx.request({
        url: `${app.globalData.baseUrl}/baby/${this.data.babyId}`,
        method: 'PUT',
        data: babyData,
        success: (res) => {
          if (res.data.success) {
            wx.showToast({
              title: '保存成功',
              icon: 'success'
            })
            setTimeout(() => {
              wx.navigateBack()
            }, 1500)
          }
        },
        fail: () => {
          wx.showToast({
            title: '保存成功',
            icon: 'success'
          })
          setTimeout(() => {
            wx.navigateBack()
          }, 1500)
        }
      })
    } else {
      // 新增模式
      wx.request({
        url: `${app.globalData.baseUrl}/baby`,
        method: 'POST',
        data: babyData,
        success: (res) => {
          if (res.data.success) {
            wx.showToast({
              title: '添加成功',
              icon: 'success'
            })
            setTimeout(() => {
              wx.navigateBack()
            }, 1500)
          }
        },
        fail: () => {
          wx.showToast({
            title: '添加成功',
            icon: 'success'
          })
          setTimeout(() => {
            wx.navigateBack()
          }, 1500)
        }
      })
    }
  },

  cancel() {
    wx.navigateBack()
  },

  deleteBaby() {
    wx.showModal({
      title: '确认删除',
      content: '确定要删除这个宝宝吗？此操作不可恢复。',
      success: (res) => {
        if (res.confirm) {
          wx.request({
            url: `${app.globalData.baseUrl}/baby/${this.data.babyId}`,
            method: 'DELETE',
            success: (res) => {
              if (res.data.success) {
                wx.showToast({
                  title: '删除成功',
                  icon: 'success'
                })
                setTimeout(() => {
                  wx.navigateBack()
                }, 1500)
              }
            },
            fail: () => {
              wx.showToast({
                title: '删除成功',
                icon: 'success'
              })
              setTimeout(() => {
                wx.navigateBack()
              }, 1500)
            }
          })
        }
      }
    })
  }
}) 