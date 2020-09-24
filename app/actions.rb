helpers do
    def current_user
        User.find_by(id: session[:user_id])
    end
end


get '/' do
    @finstagram_posts = FinstagramPost.order(created_at: :desc)
    erb(:index)
end

get '/signup' do #if an user navigates to the signup path
    @user = User.new #setup empty @user object
    erb(:signup) #call my signup page
end

post '/signup' do
    #grab user input values from params
    email = params[:email]
    avatar_url = params[:avatar_url]
    username = params[:username]
    password = params[:password]
    
    #instantiate an user
    @user = User.new({email: email, avatar_url: avatar_url, username: username, password: password})
    
    #if user validations pass and user is saved
    if @user.save
        #after saving a new user go to login page
        redirect to('/login')
    else
        #go back to signup form
        erb(:signup)
    end
end

get '/login' do #when a GET request comes into /login
    erb(:login) #render app/views/login.erb
end

post '/login' do
    username = params[:username]
    password = params[:password]

    #1 find user by username
   @user = User.find_by(username: username)

    #2 if user exists and passwords match in record
    if @user && @user.password == password
        session[:user_id] = @user.id
        redirect to('/')
    else
        @error_message = "Login failed"
        erb(:login)
    end
end

get '/logout' do
    session[:user_id] = nil
    redirect to('/')
end

get '/finstagram_posts/new' do
    @finstagram_post = FinstagramPost.new
    erb(:"finstagram_posts/new")
end

post '/finstagram_posts' do
    
    photo_url = params[:photo_url]

    #instantiate new FinstagramPost
    @finstagram_post = FinstagramPost.new({ photo_url: photo_url, user_id: current_user.id })

    #if @post validates, save
    if @finstagram_post.save
        redirect(to('/'))
    else
        #if doesn't validate, reload with error messages
        erb(:"finstagram_posts/new")
    end

end

get '/finstagram_posts/:id' do
  @finstagram_post = FinstagramPost.find(params[:id]) #find the post with the ID from the URL
  erb(:"finstagram_posts/show") #render app/views/finstagram_posts/show.erb
end

post '/comments' do
   # point values from params to variables
  text = params[:text]
  finstagram_post_id = params[:finstagram_post_id]

  # instantiate a comment with those values & assign the comment to the `current_user`
  comment = Comment.new({ text: text, finstagram_post_id: finstagram_post_id, user_id: current_user.id })

  # save the comment
  comment.save

  # `redirect` back to wherever we came from
  redirect(back)
end


post '/likes' do
  #this post method is very similar to the post comments one, look at the differences in both  
  finstagram_post_id = params[:finstagram_post_id]

  like = Like.new({ finstagram_post_id: finstagram_post_id, user_id: current_user.id })
  like.save

  redirect(back)
end

delete '/likes/:id' do

  like = Like.find(params[:id])
  like.destroy
  redirect(back)
  
end