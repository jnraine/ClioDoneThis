# ClioDoneThis - iDoneThis via Terminal

Setting up..

1. Add the following aliases to your bash profile. You can customise the aliases to better suit your own needs, just remember to replace the ares where I have put 'yourUsername' and other things like it with your own. 
```shell
alias did='function __didit() { idonethis.rb --post_done "$*"; unset -f __didit; }; __didit' 
```
```shell
alias didcomment='idonethis.rb --comment_done' 
```
```shell
alias diduncomment='idonethis.rb --uncomment_done' 
```
```shell
alias didlike='idonethis.rb --like_done' 
```
```shell
alias didnotlike='idonethis.rb --unlike_done' 
```
```shell
alias undid='idonethis.rb --delete_done' 
```
```shell
alias didlc='function __diditlc() { lc=$(git log -1 --pretty=%B);did $lc; unset -f __diditlc; }; __diditlc' 
```
```shell
alias dones='idonethis.rb --get_dones "yourUsername"' 
```
```shell
alias pdones='idonethis.rb --get_dones ""' 
```
```shell
alias tdones='idonethis.rb --get_dones "teamMember1Username,teamMember2Username"' 
```

2. Also add the following - the API key you can get from your iDoneThis account. The username is your iDoneThis username, the cookies are a little bit more complicated. iDoneThis' API does not yet support.... deleting dones, commenting on dones (or deleting comments) or liking dones... so I wrote a not so pretty means to get around that, but it requires your cookie from the web. This is easy to get (see screenshot below) and does not expire, so if you want to use those features take the cookie stuff as seen in the screen shot and put it in here in the format shown below.

```shell
export IDONETHIS_API_KEY="*********************" 
```
```shell
export IDONETHIS_USERNAME="********" 
```
```shell
export IDONETHIS_DELETE_COOKIE="{ 'Host' => '****', 'Connection' => '*****', 'Accept' => '*******', 'Origin' => '***', 'X-Requested-With' => '***', 'User-Agent' => '****', 'X-CSRFToken' => '******', 'Referer' => '*****', 'Accept-Encoding' => '*****', 'Accept-Language' => '******', 'Cookie' => '*********'}" 
```
```shell
export IDONETHIS_COMMENT_COOKIE="same format as above" 
```
```shell
export PATH=$PATH:/path/to/ClioDoneThis 
```
  
3. DONE.
