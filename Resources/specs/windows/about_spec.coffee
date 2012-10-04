require('../helpers/SpecHelper');

describe("Windows/About", () ->
  view_proxy = null
  detail_view_proxy = null
  about_page1 = null
  about_page2 = null
  
  beforeEach(() ->
    about_page1 = Factory('about_us_subpage')
    about_page2 = Factory('about_us_subpage', {title: "Mission"})
    spyOn(Cloud.Objects, 'query').andCallFake((query, cb) -> cb({success: true, AboutUsPage: [about_page1, about_page2]}))
    spyOn(Twitter, 'tweet').andCallFake((cb) -> cb({success: true}))
    spyOn(FbGraph, 'wallPost').andCallFake((cb) -> cb({success: true}))
    view_proxy = Windows.About()
    detail_view_proxy = view_proxy.detail_view_proxy
    PropertyCache.setup({cache_time: 10000})
    view_proxy.win.open()
    view_proxy.win.fireEvent('focus')
  )
  
  it('only gets the page after a certain amount of cache time', () ->
    view_proxy.win.fireEvent('focus')
    expect(Cloud.Objects.query.callCount).toEqual(1)
    PropertyCache.setup({cache_time: 1});
    sleep(10)
    view_proxy.win.fireEvent('focus')
    expect(Cloud.Objects.query.callCount).toEqual(2)
  )

  it("puts photo on the page", ()->
    expect(detail_view_proxy.photo.image).toEqual("http://storage.cloud.appcelerator.com/bx017YfidhbNRHRMlhZCTl4dOy8Ug9qH/photos/c1/ab/506c90c79e73795f3b000292/charity1_medium_640.jpeg");
  )
  
  it("puts content from ACS on the page", ()->
    expect(detail_view_proxy.content.text).toMatch('This is copy that we have for the About Us page.');
  )
  
  it("puts title from ACS on the page", ()->
    expect(detail_view_proxy.title.text).toMatch('About Us');
  )
    
  it("adds a tweet button to the page", ()->
    detail_view_proxy.tweet_button.fireEvent('click')
    expect(Twitter.tweet).toHaveBeenCalled()
  )
  
  it("adds a fb share button to the page", () ->
    detail_view_proxy.fb_button.fireEvent('click')
    expect(FbGraph.wallPost).toHaveBeenCalled()
  )
  
  it("changes the view when you click the subnav", ()->
    view_proxy.subnav.children[1].fireEvent('click')
    expect(detail_view_proxy.title.text).toMatch("Mission")
  )
  
  it("evenly distributes the other subnav", ()->
    expect(view_proxy.subnav.children[1].width).toEqual(174.54545454545456)
  )
  
  it("makes the main subnav large", ()->
    expect(view_proxy.subnav.children[0].width).toEqual(145.45454545454544)
  )
  
  it("moves the subnav into the correct positions", ()->
    expect(view_proxy.subnav.children[0].left).toEqual(0)
    expect(view_proxy.subnav.children[1].left).toEqual(145.45454545454544)
  )

  it('only shows 2 subnav items on first window focus', ()->
    expect(view_proxy.subnav.children.length).toEqual(2)
  )
  
  xit('still only shows the original 2 subnav items on window focus and does not duplicate them each time the window is focused on', ()->
    view_proxy.win.fireEvent('focus')
    view_proxy.subnav.children.map((c)->
      log("childe\n")
      log(c)
    )
    expect(view_proxy.subnav.children.length).toEqual(2)
  )
  
)  
