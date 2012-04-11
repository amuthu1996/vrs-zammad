$ = jQuery.sub()

class Index extends App.ControllerLevel2
  toggleable: true

  menu: [
    { name: 'Web',      'target': 'web',      controller: App.ChannelWeb },
    { name: 'Mail',     'target': 'email',    controller: App.ChannelEmail },
    { name: 'Chat',     'target': 'chat',     controller: App.ChannelChat },
    { name: 'Twitter',  'target': 'twitter',  controller: App.ChannelTwitter },
    { name: 'Facebook', 'target': 'facebook', controller: App.ChannelFacebook },
  ] 
  page: {
    title:     'Channels',
    sub_title: 'Management'
    nav:       '#channels',
  }

  constructor: ->
    super

    # render page
    @render()

Config.Routes['channels'] = Index
