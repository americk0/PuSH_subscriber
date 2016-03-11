# == Schema Information
#
# Table name: feeds
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  feed_url   :string
#

class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]
  skip_before_filter  :verify_authenticity_token # skip token auth

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all
  end

  # subscribes to a hub
  def subscribe
    uri = URI.parse params[:hub]
    post_params = {
      'hub.mode' => 'subscribe',
      'hub.topic' => params[:topic],
      'hub.callback' => 'http://benjamin-watson-push-client.herokuapp.com/webhook',
      'hub.verify' => 'sync'
    }
    Net::HTTP.post_form uri, post_params

    respond_to do |format|
      format.html { redirect_to :feeds, notice: 'subscription added' }
    end
  end

  def sample
    puts 'params is: ' + params.inspect
    respond_to do |format|
      format.html { render plain: 'good ' + params.inspect }
    end
  end

  # called by hub to send RSS
  def webhook
    @challenge = params['hub.challenge']

    # setup doc to be a usable Nokogiri object
    xml = request.body.read
    xml.gsub!(/\n */, '')
    doc = Nokogiri::XML(xml)
    doc.remove_namespaces!

    # ensure doc is a Nokogiri object before continuing
    unless doc.xpath('.//title')[0].nil?

      # find a feed or create a new one
      feed_url = doc.xpath('.//feed/status')[0].attribute('feed').value
      @feed = Feed.find_or_create_by(feed_url: feed_url)
      @feed.title = doc.xpath('.//feed/title')[0].inner_text
      @feed.save!

      doc.xpath('.//feed/entry').each do |entry|
        entry_id = entry.xpath('./id')[0].inner_text
        @entry = Entry.find_or_create_by(feed_id: @feed.id, entry_id: entry_id)
        @entry.title = entry.xpath('./title')[0].inner_text
        @entry.body = entry.xpath('./summary')[0].inner_text
        @entry.author = entry.xpath('./author/name')[0].inner_text
        @entry.save!
      end

    else
      puts 'PROBLEM: rss message empty'
    end

    respond_to do |format|
      format.html { render plain: @challenge, status: 200 }
    end

  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(feed_params)

    respond_to do |format|
      if @feed.save
        format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: 'Feed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:title, :feed_url)
    end
end
