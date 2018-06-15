# 20180615 with LikeLion DAY7

### 간단과제

#### ASK 만들기

* ASK 모델과 ASK Controller를 만든다.

  > ask 모델의 column
  >
  > * ip address
  > * region
  > * Question(우선은 이것부터)

* `/ask` => 나에게 등록된 모든 질문을 출력

* `/ask/new` : 새로운 질문을 작성하는 곳.

  > 모델 만들기 -> Route설정 -> Controller 작성 -> View 파일 만들기.

## 간단과제

### ASK만들기

- `ask` 모델과 `ask_controller`를 만듭니다.

> ask 모델의 column
>
> - question

- `/ask` : 나에게 등록된 모든 질문을 출력
- `/ask/new` : 새로운 질문을 작성하는 곳

> 모델 만들고 route 설정하고 controller 작성하고 view파일 만들기

```command
$ rails g model ask
$ rails g controller ask
```



#### Index, New, Show

*db/migrate/create_asks.rb*

```ruby
class CreateAsks < ActiveRecord::Migration[5.0]
  def change
    create_table :asks do |t|
      t.text "question"  # 질문을 저장할 question 이라는 컬럼을 지정해줌
      t.timestamps
    end
  end
end

```

*config/routes.rb*

```ruby
...
  get '/ask' => 'ask#index'
  get '/ask/new' => 'ask#new'
  post '/ask/create' => 'ask#create'
  get '/ask/:id/show' => 'ask#show'
...
```

- 전체 목록을 보는 `/ask`액션과 새로운 질문을 등록하는 `/ask/new`, 실제로 글이 저장되는 `/ask/create` 까지 만들어줌

*app/controllers/ask_controller.rb*

```ruby
class AskController < ApplicationController
    
    def index
        @asks = Ask.all
    end
    
    def new
      
    end
    
    def create
        a1 = Ask.new
        a1.question = params[:question]
        a1.ipaddress = request.ip
        a1.region = request.location.region
        a1.save
        redirect_to '/ask'
    end
  
    ...
        
    def show 
        @ask = Ask.find(params[:id])
    end
end
```

- 인덱스에서는 모든 질문을 보여주기 위해서 `.all` 메소드로 해당 테이블에 있는 모든 내용물을 불러 올 수 있다. 이는 Rails에 내장되어있는 ORM인 ActiveRecord가 가지고 있는 메소드 덕분인데, DB의 테이블 조작을 SQL로 하는 것이 아니라 루비 문법으로 조작할 수 있게 해주는 기능이다.

*app/views/ask/index.html.erb*

```erb
<a href="/ask/new">새 질문 등록하기</a>

<ul>
    <% @asks.reverse.each do |ask| %>
        <li><%= ask.question %></li>
    <% end %>
</ul>
```

- 상단에는 새 글을 등록할 수 있는 버튼이 있고 아래에는 저장된 질문 목록을 볼 수 있다.
- 지금 전체적으로 view가 못생겼다.. 아무런 css 를 추가하지 않았기 때문인데 bootstrap이라는 좋은 css, js 라이브러리를 활용하여 더 아름답게 만들어보자.

*Gemfile*

```ruby
gem 'bootstrap', '~> 4.1.1'
```

```command
$ bundle install
```

- bootstrap은 최근에 4버전으로 업데이트 되면서 Gem도 업데이트 됐다. 기존의 3버전을 쓰기 위해서는 `bootstrap` Gem 대신에 `gem 'bootstrap-sass'`를 설치해야 한다.

*app/assets/javascripts/application.js*

```js
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require turbolinks
//= require_tree .
```

*app/assets/stylesheets/application.scss*

```scss
@import "bootstrap";
```

>  기존에 css 파일은 확장자가 `.css` 인데 파일명 수정으로 `.scss`로 바꿔줘야 한다.

- 이렇게 하면 bootstrap 4 버전을 사용할 수 있다. class 속성을 주는 것만으로 view를 아름답게 할 수 있다.

*app/views/ask/index.html.erb*

```erb
<div class ="text-center">
</div>
<ul class ="list-group">
    <% @asks.reverse.each do |ask| %>
    <li class ="list-group-item"><%= ask.question %>
    <small>(<%=ask.ipaddress%>, <%=ask.region%>)</small>
        <a href = "/ask/<%=ask.id%>/show" class="btn btn-success">내용보기</a>
        <a href= "/ask/<%= ask.id %>/edit" class = "btn btn-primary">수정</a>
        <a a data-confirm="해당 글을 삭제하시겠습니까?" 
        class ="btn btn-danger" href = "ask/<%= ask.id%>/delete">삭제</a>
    </li>
    <% end %>
</ul>

```

*app/views/layouts/application.html.erb*

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>테스트용</title>
    <%= csrf_meta_tags %>
    <meta name ="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <div class="d-flex flex-column flex-md-row align-items-center p-3 px-md-4 mb-3 bg-white border-bottom box-shadow">
      <h5 class="my-0 mr-md-auto font-weight-normal">손수 한땀한땀 만든 ASK</h5>
      <nav class="my-2 my-md-0 mr-md-3">
        <a class="p-2 text-dark" href="/ask">홈으로</a>
        <a class="p-2 text-dark" href="/ask/new">질문하기</a>
      </nav>
    </div>
    
    <div class ="container">
    <%= yield %>
    </div>
  </body>
</html>

```

- nav바와 내용물을 가운데로 몰아주는 `container` 속성을 추가했다.

### 다음은 질문의 내용을 따로 보여주는 Show화면이다.

*app/views/ask/show.html.erb*

```ruby
<div class = "text-center">
<nav aria-label="breadcrumb">
     <h1>질문의 내용은 다음과 같습니다.</h1>
  <ol class="breadcrumb">
    <li class="breadcrumb-item active" aria-current="page"><%= @ask.question%></li>
  </ol>
  <a href ="/ask" class="btn btn-info">뒤로가기</a>
</nav>
</div>
```



#### Delete

- CRUD 중에서 D는 Delete 혹은 Destroy, 삭제를 의미한다.
- 삭제하는 로직은 단순하다. 찾아서 삭제하고 다시 원래 페이지로 돌아가면 된다.

*config/routes.rb*

```ruby
...
  get '/ask/:id/delete' => 'ask#delete'
...
```

- RESTful 하게 구현하려면 http method 중에서 `delete` 방식을 사용해야하지만 지금은 `get` 방식으로 처리한다.

*app/controllers/ask_controller.rb*

```ruby
...
def delete
    ask = Ask.find(params[:id])
    ask.destroy
    redirect_to "/ask"
end
...
```

- 첫줄은 해당 row를 id로 검색해서 `ask`라는 변수에 담고, `ask.destroy`를 통해 삭제하고 원래의 페이지로 리디렉션을 걸어준다.

```erb
...
<ul class="list-group">
    <% @asks.reverse.each do |ask| %>
    <li class="list-group-item">
        <%= ask.question %>
        <a data-confirm="이 글을 삭제하시겠습니까?" class="btn btn-danger" href="/ask/<%= ask.id %>/delete">삭제</a></li>
    <% end %>
</ul>
```

- html 속성 중에서 `data-confirm`이라는 속성은 js코드를 쓰지 않고 `confirm`을 이용할 수 있다. `alert`는 안된다.



#### Edit, Update

- 수정 로직도 간단하다. 찾고 데이터를 바꾸고 저장하고, 원래의 페이지로 돌아간다. 다만 사용자에게 수정하는 페이지를 주기 위한 `edit` 액션에도 수정하기 전의 데이터를 보여주기 위해서 찾는 로직이 포함된다.

*config/routes.rb*

```ruby
...
  get'/ask/:id/edit' => 'ask#edit'
  post '/ask/:id/update' => 'ask#update'
...
```

*app/controllers/ask_controller.rb*

```ruby
...   
def edit
    @ask = Ask.find(params[:id])
end

def update
    ask = Ask.find(params[:id])
    ask.question = params[:question]
    ask.save
    redirect_to '/ask'
end
...
```

- `edit` 액션에서도 params로 넘어온 id로 검색해서 table에서 해당 row를 검색하여 `@ask` 변수에 넣어 사용한다. 마찬가지로 서버와 클라이언트의 connection은 req, res 한번에 끊기기 때문에 다음 `update` 액션에도 id를 넘겨서 검색하고 수정하고 저장하는 로직이 포함되어야 한다.



#### 사용자의 IP와 Geocoder

- 작은 재미를 위해 이 사이트를 사용하는 사용자의 ip와 사용자가 있는 도시의 이름을 저장하는 코드를 추가했다.

*Gemfile*

```ruby
...
  gem 'geocoder'
...
```

```command
$ bundle install
```

*db/migrate/create_asks.rb*

```ruby
class CreateAsks < ActiveRecord::Migration[5.0]
  def change
    create_table :asks do |t|
      
      t.text "question"
      t.string "ip_address"
      t.string "region"

      t.timestamps
    end
  end
end

```

*app/controllers/ask_controller.rb*

```ruby
...
def create
    ask = Ask.new
    ask.question = params[:q]
    ask.ip_address = request.ip
    ask.region = request.location.region
    ask.save
    redirect_to "/ask"
end
...
```

- 실제 DB에 저장될 때 요청이 온 ip를 저장하면 사용자의 ip와 ip를 기반으로 한 사용자의 위치까지 저장할 수 있다.

### 최종 결과물

1.bootstrap을 사용하기 위해서 다음과 같은 설정을 한다.

*app/assets/javascripts/application.js* 

```
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require turbolinks
//= require_tree .
```

*app/assets/javascripts/stylesheets/application.scss* 

* 해당 파일은 확장자를 scss로 만들어준다.아니면 읽어오지 못함

```scss
@import "bootstrap";
```

*gemfile*

```
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'bootstrap', '~> 4.1.1'
gem 'geocoder'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

2. Controller 단을 구성한다.

*ask_controller.rb*

```ruby
class AskController < ApplicationController
    
    def index
        @asks = Ask.all
    end
    
    def new
      
    end
    
    def create
        a1 = Ask.new
        a1.question = params[:question]
        a1.ipaddress = request.ip
        a1.region = request.location.region
        a1.save
        redirect_to '/ask'
    end
    
    def delete
        ask = Ask.find(params[:id])
        ask.destroy
        redirect_to '/ask'
    end
    
    def edit
        @ask = Ask.find(params[:id]) 
    end
    
    def update
        ask = Ask.find(params[:id])
        ask.question = params[:question]
        ask.save
        redirect_to '/ask'
    end
    
    def show
        @ask = Ask.find(params[:id])
    end
end
```

3. Route를 구성한다.

*config/route.rb*

```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index' # get '/' => 'home#index' 
  get '/ask' => 'ask#index'
  get '/ask/new' => 'ask#new'
  post '/ask/create' => 'ask#create'
  get '/ask/:id/delete/' => 'ask#delete'
  get '/ask/:id/edit' => 'ask#edit'
  post '/ask/:id/update' => 'ask#update'
  get '/ask/:id/show' => 'ask#show'
end
```

4. Migration 파일을 수정한다.

*db/migrate/20180615003804_create_asks.rb*

```ruby
class CreateAsks < ActiveRecord::Migration[5.0]
  def change
    create_table :asks do |t|
      t.text "question"
      t.string "ipaddress"
      t.string "region"
      t.timestamps
    end
  end
end
```

5. View 파일을 만든다.

*views/ask/index.html.erb*

```erb
<div class ="text-center">
</div>
<ul class ="list-group">
    <% @asks.reverse.each do |ask| %>
    <li class ="list-group-item"><%= ask.question %>
    <small>(<%=ask.ipaddress%>, <%=ask.region%>)</small>
        <a href = "/ask/<%=ask.id%>/show" class="btn btn-success">내용보기</a>
        <a href= "/ask/<%= ask.id %>/edit" class = "btn btn-primary">수정</a>
        <a a data-confirm="해당 글을 삭제하시겠습니까?" 
        class ="btn btn-danger" href = "ask/<%= ask.id%>/delete">삭제</a>
    </li>
    <% end %>
</ul>
```

*views/ask/new.html.erb*

```erb
<div class="form-group">
<form action="/ask/create" method ="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
    <label for="InputQuestion">질문하세요</label>
    <input class ="form-control" type= "text" name ="question" placeholder="새로운 질문을 입력해주세요!">
    <input class = "btn btn-dark" type="submit" name="질문제출">
</form>
</div>
```

*views/ask/show.html.erb*

```erb
<div class = "text-center">
<nav aria-label="breadcrumb">
     <h1>질문의 내용은 다음과 같습니다.</h1>
  <ol class="breadcrumb">
    <li class="breadcrumb-item active" aria-current="page"><%= @ask.question%></li>
  </ol>
  <a href ="/ask" class="btn btn-info">뒤로가기</a>
</nav>
</div>
```

*views/ask/edit.html.erb*

```erb
<div class="form-group">
<form action= "/ask/<%=@ask.id%>/update" method ="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
    <label for="InputQuestion">수정하세요</label>
    <input class ="form-control" type= "text" name ="question" value="<%=@ask.question%>">
    <input class = "btn btn-dark" type="submit" name="질문제출">
</form>
</div>
```



#### 간단과제

* 처음부터 twitter 만들어보기
* Table(Model) : *board*
* Controller: *tweet_controller*
  * action : *index, show, new, edit, create, update, destroy*
* View:*index*, *show*, *new*, *edit*
* bootstrap 적용하기.
* 작성한 사람의  IP주소 저장하기

#### 결과

*route.rb*

```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    get '/twitter' => 'twitter#index'
    get '/twitter/:id/show' => 'twitter#show'
    get '/twitter/new' => 'twitter#new'
    get '/twitter/:id/edit' => 'twitter#edit'
    get '/twitter/:id/destroy' => 'twitter#destroy'
    post '/twitter/:id/create' => 'twitter#create'
    post '/twitter/:id/update' => 'twitter#update'

end
```

*twitter_controller.rb*

```ruby
class TwitterController < ApplicationController

def index 
    @tweets = Twitter.all
end

def new
    
end 

def create
    tweet = Twitter.new
    tweet.board = params[:board]
    tweet.username = params[:username]
    tweet.ip_address = request.ip
    tweet.save
    redirect_to '/twitter'
end

def edit
    @tweet = Twitter.find(params[:id])
end

def update
    tweet = Twitter.find(params[:id])
    tweet.board = params[:board]
    tweet.save
    redirect_to '/twitter'
end

def destroy
    tweet=Twitter.find(params[:id])
    tweet.destroy
    redirect_to '/twitter'
end


def show
    @tweet = Twitter.find(params[:id])    
end


end	
```

*views/layout/application.html.erb*

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>TwitterApp</title>
    <%= csrf_meta_tags %>

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <div class="d-flex flex-column flex-md-row align-items-center p-3 px-md-4 mb-3 bg-white border-bottom box-shadow">
      <h5 class="my-0 mr-md-auto font-weight-normal">Twitter Example</h5>
      <nav class="my-2 my-md-0 mr-md-3">
        <a class="p-2 text-dark" href="/twitter">Home</a>
        <a class="p-2 text-dark" href="/twitter/new">new Tweet</a>
      </nav>
    </div>
    
    <%= yield %>
  </body>
</html>
```

*views/twitter/index.html.erb*

```erb
<main role="main" class="container">
<div class="my-3 p-3 bg-white rounded box-shadow">
        <h6 class="border-bottom border-gray pb-2 mb-0">Recent updates</h6>
        <%@tweets.reverse.each do |tweet|%>
        <div class="media text-muted pt-3">
          <img data-src="holder.js/32x32?theme=thumb&amp;bg=007bff&amp;fg=007bff&amp;size=1" alt="32x32" class="mr-2 rounded" style="width: 32px; height: 32px;" src="data:image/svg+xml;charset=UTF-8,%3Csvg%20width%3D%2232%22%20height%3D%2232%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2032%2032%22%20preserveAspectRatio%3D%22none%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%23holder_16403d39d19%20text%20%7B%20fill%3A%23007bff%3Bfont-weight%3Abold%3Bfont-family%3AArial%2C%20Helvetica%2C%20Open%20Sans%2C%20sans-serif%2C%20monospace%3Bfont-size%3A2pt%20%7D%20%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%20id%3D%22holder_16403d39d19%22%3E%3Crect%20width%3D%2232%22%20height%3D%2232%22%20fill%3D%22%23007bff%22%3E%3C%2Frect%3E%3Cg%3E%3Ctext%20x%3D%2211.84375%22%20y%3D%2216.95625%22%3E32x32%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E" data-holder-rendered="true">  
          <p class="media-body pb-3 mb-0 small lh-125 border-bottom border-gray">
              <strong class="d-block text-gray-dark">@<%=tweet.username%></strong>
              <%=tweet.board%><small>(<%=tweet.ip_address%>)</small>
          </p>
        </div>
        <small class="d-block text-right mt-3"><a href ="twitter/<%=tweet.id%>/edit">edit</a>
       <a a data-confirm="해당 글을 삭제하시겠습니까?" href ="twitter/<%=tweet.id%>/destroy">delete</a></small>
      <%end%>
      <small  class="d-block text-right mt-3"><a href ="twitter/new">new Tweet</a></small>
</div>
    </main>
```

*views/twitter/new.html.erb*

```erb
<body>
    <form class="form-signin container" action='twitter/create' method="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
      <div class="form-label-group">
        <input type="text" name="username" class="form-control" placeholder="닉네임을 입력하세요!" required="" autofocus="">
        <br/>
      </div>

      <div class="form-label-group">
        <input type="msg" name="board" class="form-control" placeholder="뻘글을 싸지르세요!" required="">
        <br/>
      </div>
    <div>
      <button class="btn btn-lg btn-primary btn-block" type="submit">싸지르기! 끼요오옷!</button>
      <p class="mt-5 mb-3 text-muted text-center">© 2018</p>
    </div>
    </form>
  

</body>
```

*views/twitter/edit.html.erb*

```erb
<body>
    <form class="form-signin container" action= "/twitter/<%=@tweet.id%>/update" method ="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
      <div class="text-center mb-4">
        <img class="mb-4" src="https://getbootstrap.com/assets/brand/bootstrap-solid.svg" alt="" width="72" height="72">
        <h1 class="h3 mb-3 font-weight-normal">수정할 내용이 있나요?</h1>
        <p>그렇다면 얼른 다른 개소리로 바꿔주세요!</p>
      </div>

      <div class="form-label-group">
       <input class ="form-control" type= "text" name ="board" value="<%=@tweet.board%>" required="" autofocus="">
        <label for="inputEmail">Email address</label>
      </div>

      <button class="btn btn-lg btn-primary btn-block" type="submit">뻘글 일발장전! 발사!</button>
      <p class="mt-5 mb-3 text-muted text-center">©2018</p>
    </form>
  

</body>
```

*views/twitter/show.html.erb*

```erb
<body>
   <form class="form-signin container" action= "/twitter/<%=@tweet.id%>/update" method ="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
      <div class="text-center mb-4">
        <img class="mb-4" src="https://getbootstrap.com/assets/brand/bootstrap-solid.svg" alt="" width="72" height="72">
        <h1 class="h3 mb-3 font-weight-normal">개소리를 더 보여드리겠습니다.</h1>
      </div>
   <div class = "text-center container">
   <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item active" aria-current="page"><%=@tweet.board%></li>
      </ol>
      <a href ="/twitter" class="btn btn-info">뒤로가기</a>
</nav>   
</div>
</body>
```

