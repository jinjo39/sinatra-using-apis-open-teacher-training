describe 'Application Controller' do 
  describe 'root path' do 
    it 'renders the user input-a-mood form' do 
      get '/'
      expect(last_response.body).to include('<form action="/moods" method="POST">')
    end
  end
end