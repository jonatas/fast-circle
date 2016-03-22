# Fast circle

It connects on circle and look for repeated builds in the same branch. It
cancel the old builds keeping only latest commit in each branch.

It doesn't cancel builds on master branch.

## Setup your keys

1. Create or get your key on [Circle CI api](https://circleci.com/account/api).
2. Set your environment variable on a `.env` file in the main directory of
   these project


I recommend you to use `.env` with the following keys.

```
CI_TOKEN=myAwesomeToken
CI_REPOSITORY="ideia.me"
CI_USERNAME="jonatas"
```

## Test if it works in localhost

    ruby ./avoid-double-build-on-branch.rb

## Deploying to heroku

Create the repo on heroku:

    heroku create


Setup your keys on heroku:

```
heroku config:set CI_TOKEN=myAwesomeToken \
  CI_REPOSITORY="ideia.me" \
  CI_USERNAME="jonatas"
```

### Test on heroku

    heroku run ruby ./avoid-double-build-on-branch.rb

If it works like in heroku via `heroku run`, configure it to heroku scheduler.

Setup the Heroku Scheduler

    heroku addons:create scheduler:standard
 
Configure it via web:

    heroku addons:open scheduler

Click on "Add Job..."

After that, fill on "run command" input field:

    ruby ./avoid-double-build-on-branch.rb

Configure it to run each 10 minutes.
