describe 'User interacting with the site' do 
  it 'successfully shows a user a page with giphs that match their search' do 
    VCR.use_cassette('/moods/happy') do 
      visit '/'
      fill_in "keyword", :with => "happy"
      click_on "Submit"
      expect(current_path).to eq('/moods')
      expect(!!page.body.match('<img src="http://media1.giphy.com/media/ENQ5oH9FHOKiI/200.gif"')).to be true
    end
  end
end
