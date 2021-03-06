#   Copyright (c) 2012-2016, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

include Warden::Test::Helpers

feature 'Libraries on welcome page' do
  setup do
    @user = create :user

    @library = create :public_library_with_elements, name: 'envogue', user: @user
    @library.popularity = 1000
    @library.save

    @admin = create :admin_user
  end

  scenario 'Personalized library section' do
    # Create two hearts (including new libraries)
    heart1 = create :heart, user: @user
    heart2 = create :heart, user: @user

    # When the user is not logged in, there should be no personalized library section at all.
    visit root_path
    refute page.has_content?(heart1.heartable.name)
    refute page.has_content?(heart2.heartable.name)

    # When the user is logged in has hearted at least two libraries they should be displayed.
    login_as @user
    visit root_path
    assert page.has_content?(heart1.heartable.name)
    assert page.has_content?(heart2.heartable.name)
  end

  scenario 'Combined scenario for trending libraries' do
    login_as @admin

    # When no libraries are audited, the box on the welcome page should not be displayed
    visit root_path
    refute page.has_content?(I18n.t 'welcome.trending_libraries.heading')

    # enable library for welcome page
    visit libraries_path
    within "#library#{@library.id}" do
      click_on I18n.t 'library.auditing.welcome_page_disabled'
    end

    # visit welcome page, library should be shown
    visit root_path
    page.must_have_content I18n.t 'welcome.trending_libraries.heading'
    page.must_have_content 'envogue'

    logout
    login_as @user
    visit library_path(@library)

    # User should be warned before editing it
    page.must_have_content I18n.t 'library.auditing.user_warning'

    # User changes the name of an enabled library after which it gets disabled
    fill_in "library#{@library.id}_library_name", with: 'notanymore'
    click_button I18n.t 'formtastic.actions.update'

    # visit welcome page
    visit root_path
    refute page.has_content?('notanymore')
  end
end

feature 'Libraries on category pages' do
  setup do
    @user = create :user
    @library = create(:library, :public, user: @user)

    @category = create :category
    @category_child = create(:category, parent: @category)
    @category_grandchild = create(
      :category, parent: @category_child)
  end

  scenario 'library is shown on category page unless owner is logged in' do
    articles = []
    3.times do
      articles.push create(
        :article, seller: @user, categories: [@category])
    end

    articles.each do |article|
      create(:library_element, library: @library, article: article)
    end

    visit category_path(@category)
    page.must_have_content(@library.name)

    login_as @user
    visit category_path(@category)
    page.wont_have_content(@library.name)
  end

  scenario 'library is shown on parent category page' do
    articles = []
      .push(create(
              :article, seller: @user, categories: [@category]))
      .push(create(
              :article, seller: @user, categories: [@category_child]))
      .push(create(
              :article, seller: @user, categories: [@category_grandchild]))

    articles.each do |article|
      create(:library_element, library: @library, article: article)
    end

    visit category_path(@category)
    page.must_have_content(@library.name)
  end
end

feature 'Libraries on library pages' do
  scenario 'more libraries of the same user are shown on a library page' do
    user = create :user
    library1 = create(:public_library_with_elements, user: user)
    library2 = create(:public_library_with_elements, user: user)

    visit library_path(library1)
    page.must_have_content(library2.name)
  end
end

feature 'Library management' do
  setup do
    @user = create :user
    login_as @user.reload # reload to get default library
  end

  scenario 'user creates new library' do
    visit user_libraries_path @user
    page.must_have_content I18n.t 'library.new'
    within '#new_library' do
      fill_in 'new_library_name', with: 'foobar'
      click_button I18n.t('library.create')
    end
    page.must_have_selector 'a', text: 'foobar'
  end

  scenario 'user creates a library with a blank name' do
    visit user_libraries_path @user
    click_button I18n.t('library.create')
    page.must_have_content I18n.t 'activerecord.errors.models.library.attributes.name.blank'
  end

  scenario 'user updates name of existing Library' do
    library = create :library, name: 'foobar', user: @user
    visit user_libraries_path @user
    click_link 'foobar'
    within "#edit_library_#{library.id}" do
      fill_in "library#{library.id}_library_name", with: 'bazfuz'
      click_button I18n.t 'formtastic.actions.update'
    end
    page.must_have_content 'bazfuz'
  end

  scenario 'user updates library with a blank name' do
    library = create :library, name: 'foobar', user: @user
    visit user_libraries_path @user
    click_link 'foobar'
    within "#edit_library_#{library.id}" do
      fill_in "library#{library.id}_library_name", with: ''
      click_button I18n.t 'formtastic.actions.update'
    end

    page.must_have_content 'foobar'
    page.must_have_content I18n.t('activerecord.errors.models.library.attributes.name.blank')
  end

  scenario 'user deletes Library' do
    create :library, name: 'foobar', user: @user
    visit user_libraries_path @user
    click_link 'foobar'
    assert_difference 'Library.count', -1 do
      within '.library-edit-settings' do
        click_link I18n.t('library.delete')
      end
    end
    page.wont_have_content 'foobar'
  end

  scenario 'user adds an Article to his default Library' do
    @article = create :article
    visit article_path(@article)
    page.has_css?('div.libraries_list a', :count == 1) # There should be exactly one library link (default library) before adding

    click_link I18n.t 'library.default'
    page.must_have_content I18n.t('library_element.notice.success')[0..10] # shorten string because library name doesn't get evaluated
    page.has_css?('div.libraries_list a', :count == 0) # After adding the article, the library link should be removed

    visit user_libraries_path @user
    click_link I18n.t 'library.default'
    page.must_have_content @article.title[0..10] # characters get cut off on page as well
  end

  scenario 'seller removes an article that buyer has in his library' do
    seller = @user
    article = create :article, seller: seller
    buyer = create :buyer
    library = create :library, user: buyer, public: true
    create :library_element, article: article, library: library

    login_as seller
    visit article_path article
    click_button I18n.t('article.labels.deactivate')
    logout(:user)
    login_as buyer
    visit library_path library
    page.must_have_content I18n.t('common.text.no_articles')
  end
end

feature 'Library visibility' do
  before do
    UserTokenGenerator.stubs(:generate).returns('some long string that is very secret')
  end
  scenario 'user browses through libraries' do
    user = create :user
    pub_lib = create :library, user: user, public: true
    pub_lib.articles << create(:article, title: 'exhibit-article')
    priv_lib = create :library, user: user, public: false
    visit user_libraries_path user
    page.must_have_content pub_lib.name
    page.wont_have_content priv_lib.name
  end
end

feature 'Featured (exhibited) libraries' do
  scenario 'user visits root path with exhibition' do
    lib = create :library, :public, exhibition_name: 'donation_articles'
    lib.articles << create(:article, title: 'exhibit-article')
    visit root_path
    page.must_have_content 'exhibit-article'
  end

  scenario 'user visits book category front page' do
    lib = create :library, :public, exhibition_name: 'book1'
    lib.articles << create(:article, title: 'exhibit-article')
    visit category_path create :category, name: 'bucher'
    page.must_have_content 'exhibit-article'
  end

  scenario 'user visits two filter landing pages' do
    article = create :article, title: 'exhibit-article'
    lib1 = create :library, :public, exhibition_name: 'fair1'
    lib2 = create :library, :public, exhibition_name: 'used1'
    lib1.articles << article
    lib2.articles << article

    visit root_path
    find('#filter-fair').find('a').click
    page.must_have_content 'exhibit-article'

    visit root_path
    find('#filter-used').find('a').click
    page.must_have_content 'exhibit-article'
  end
end

feature 'Admin management for featured (exhibited) Libraries' do
  let(:featured_library) { create :library, :public, exhibition_name: 'donation_articles' }
  let(:article) { create :article, title: 'Foobar' }
  setup do
    login_as create :admin_user
  end

  scenario 'admin adds Article to a random Library' do
    visit root_path
    page.wont_have_link 'Foobar'

    featured_library
    visit article_path article
    select(I18n.t('enumerize.library.exhibition_name.donation_articles'), from: 'library_exhibition_name')
    click_button I18n.t 'article.show.add_as_exhibit'

    visit root_path
    page.must_have_link 'Foobar'
  end

  scenario 'admin add Article that is already in the library' do
    featured_library.articles << article
    visit article_path article
    select(I18n.t('enumerize.library.exhibition_name.donation_articles'), from: 'library_exhibition_name')

    assert_no_difference 'featured_library.articles.count' do
      click_button I18n.t 'article.show.add_as_exhibit'
    end
  end

  scenario 'admin removes an article' do
    featured_library.articles << article
    visit article_path article

    click_button 'aus *Spendenanteil*-Artikel löschen'
    visit root_path

    page.wont_have_link 'Foobar'
  end

  scenario 'admin sets a library as featured' do
    featured_library
    other_library = create :library, :public

    visit library_path other_library
    select(I18n.t('enumerize.library.exhibition_name.donation_articles'), from: 'library_exhibition_name')
    find('#select_exhibition_submit_action').click

    other_library.reload.exhibition_name.must_equal 'donation_articles'
    featured_library.reload.exhibition_name.must_equal nil
  end
end
