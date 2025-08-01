const app = getApp()
const api = require('../../utils/api.js')

Page({
  data: {
    actualAge: 0,
    suggestedAge: 0,
    selectedAge: null,
    assessmentAge: 0,
    availableAges: [],
    showQuestions: false,
    currentQuestion: 0,
    selectedAnswer: null,
    answers: [],
    questions: [],
    totalScore: 0,
    rank: 0,
    resultDescription: ""
  },

  onLoad() {
    this.loadAssessmentData()
    this.calculateAge()
  },

  loadAssessmentData() {
    // 通过API接口获取评估数据
    api.getAssessmentData().then(res => {
      if (res.data.success && res.data.data) {
        const assessmentData = res.data.data
        const availableAges = Object.values(assessmentData.assessments).map(item => ({
          month: item.month,
          title: item.title,
          description: item.description
        }))
        
        this.setData({ availableAges })
      } else {
        console.error('加载评估数据失败:', res.data)
        wx.showToast({
          title: '加载评估数据失败',
          icon: 'none'
        })
      }
    }).catch(err => {
      console.error('请求评估数据失败:', err)
      wx.showToast({
        title: '加载评估数据失败',
        icon: 'none'
      })
    })
  },

  calculateAge() {
    const currentBaby = app.globalData.currentBaby
    if (!currentBaby) return
    
    const birthday = new Date(currentBaby.birthday)
    const today = new Date()
    const ageInMonths = (today.getFullYear() - birthday.getFullYear()) * 12 + 
                        (today.getMonth() - birthday.getMonth())
    
    // 计算建议评估月龄（最接近的可用月龄）
    const suggestedAge = this.getSuggestedAge(ageInMonths)
    
    this.setData({
      actualAge: ageInMonths,
      suggestedAge: suggestedAge
    })
  },

  getSuggestedAge(actualAge) {
    const availableMonths = this.data.availableAges.map(item => item.month)
    let suggestedAge = availableMonths[0]
    
    for (let month of availableMonths) {
      if (month <= actualAge) {
        suggestedAge = month
      } else {
        break
      }
    }
    
    return suggestedAge
  },

  selectAge(e) {
    const age = e.currentTarget.dataset.age
    this.setData({
      selectedAge: age
    })
  },

  startAssessment() {
    if (!this.data.selectedAge) {
      wx.showToast({
        title: '请选择评估月龄',
        icon: 'none'
      })
      return
    }

    // 通过API接口获取对应月龄的评估内容
    api.getAssessmentByMonth(this.data.selectedAge).then(res => {
      if (res.data.success && res.data.data) {
        const assessment = res.data.data
        
        this.setData({
          questions: assessment.questions,
          assessmentAge: this.data.selectedAge,
          showQuestions: true,
          currentQuestion: 0,
          selectedAnswer: null,
          answers: new Array(assessment.questions.length).fill(null)
        })
      } else {
        wx.showToast({
          title: '加载评估内容失败',
          icon: 'none'
        })
      }
    }).catch(err => {
      console.error('请求评估内容失败:', err)
      wx.showToast({
        title: '加载评估内容失败',
        icon: 'none'
      })
    })
  },

  selectOption(e) {
    const index = e.currentTarget.dataset.index
    this.setData({
      selectedAnswer: index
    })
  },

  nextQuestion() {
    if (this.data.selectedAnswer === null) {
      wx.showToast({
        title: '请选择一个选项',
        icon: 'none'
      })
      return
    }

    // 保存当前答案
    const answers = [...this.data.answers]
    answers[this.data.currentQuestion] = this.data.selectedAnswer
    this.setData({ answers })

    // 进入下一题，清除选中状态
    const nextQuestion = this.data.currentQuestion + 1
    this.setData({
      currentQuestion: nextQuestion,
      selectedAnswer: null  // 清除选中状态
    })
  },

  previousQuestion() {
    // 返回上一题，恢复之前的答案
    const prevQuestion = this.data.currentQuestion - 1
    this.setData({
      currentQuestion: prevQuestion,
      selectedAnswer: this.data.answers[prevQuestion] || null
    })
  },

  finishAssessment() {
    if (this.data.selectedAnswer === null) {
      wx.showToast({
        title: '请选择一个选项',
        icon: 'none'
      })
      return
    }

    // 保存最后一题答案
    const answers = [...this.data.answers]
    answers[this.data.currentQuestion] = this.data.selectedAnswer
    this.setData({ answers })

    this.calculateResult()
  },

  calculateResult() {
    let totalScore = 0
    this.data.answers.forEach((answerIndex, questionIndex) => {
      if (answerIndex !== null) {
        totalScore += this.data.questions[questionIndex].options[answerIndex].score
      }
    })

    // 计算排名和描述
    const maxScore = this.data.questions.length * 5
    const percentage = (totalScore / maxScore) * 100
    let rank, description

    if (percentage >= 80) {
      rank = Math.floor(Math.random() * 10) + 1
      description = "宝宝发育非常优秀！继续保持良好的成长环境。"
    } else if (percentage >= 60) {
      rank = Math.floor(Math.random() * 20) + 11
      description = "宝宝发育良好，建议多进行相关训练。"
    } else if (percentage >= 40) {
      rank = Math.floor(Math.random() * 30) + 31
      description = "宝宝发育正常，建议加强相关能力训练。"
    } else {
      rank = Math.floor(Math.random() * 40) + 61
      description = "建议咨询专业医生，制定个性化训练计划。"
    }

    // 上传评估结果到服务器
    this.uploadResult(totalScore, rank)

    // 跳转到评估结果页面
    wx.navigateTo({
      url: `/pages/assessment-result/assessment-result?score=${totalScore}&rank=${rank}&description=${encodeURIComponent(description)}&assessmentAge=${this.data.assessmentAge}&actualAge=${this.data.actualAge}`
    })
  },

  uploadResult(score, rank) {
    const assessmentData = {
      babyId: app.globalData.currentBaby.id,
      score: score,
      rank: rank,
      answers: this.data.answers,
      assessmentAge: this.data.assessmentAge,
      actualAge: this.data.actualAge,
      assessmentDate: new Date().toISOString()
    }

    api.submitAssessment(assessmentData).then(res => {
      if (res.data.success) {
        console.log('评估结果上传成功')
      }
    }).catch(err => {
      console.log('评估结果上传失败:', err)
    })
  }
}) 