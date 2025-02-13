describe Spaceship::ConnectAPI::App do
  let(:mock_tunes_client) { double('tunes_client') }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_tunes_client).to receive(:team_id).and_return("123")
    allow(mock_tunes_client).to receive(:select_team)
    allow(mock_tunes_client).to receive(:csrf_tokens)
    allow(Spaceship::TunesClient).to receive(:login).and_return(mock_tunes_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: false, use_tunes: true)
  end

  describe '#Spaceship::ConnectAPI' do
    it '#get_apps' do
      response = Spaceship::ConnectAPI.get_apps
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::App)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.name).to eq("FastlaneTest")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
      expect(model.sku).to eq("SKU_SKU_SKU_SKU")
      expect(model.primary_locale).to eq("en-US")
      expect(model.removed).to eq(false)
      expect(model.is_aag).to eq(false)
    end

    it 'gets by app id' do
      response = Spaceship::ConnectAPI.get_app(app_id: "123456789")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::App)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
    end

    it '#get_review_submissions' do
      ConnectAPIStubbing::Tunes.stub_get_review_submissions

      response = Spaceship::ConnectAPI.get_review_submissions(app_id: "123456789-app")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmission)
      end

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmission)

      expect(model.id).to eq("123456789")
      expect(model.platform).to eq(Spaceship::ConnectAPI::Platform::IOS)
      expect(model.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)
      expect(model.submitted_date).to be_nil
    end

    it '#post_review_submission' do
      ConnectAPIStubbing::Tunes.stub_create_review_submission

      response = Spaceship::ConnectAPI.post_review_submission(app_id: "123456789-app", platform: Spaceship::ConnectAPI::Platform::IOS)
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmission)

      expect(model.id).to eq("123456789")
      expect(model.platform).to eq(Spaceship::ConnectAPI::Platform::IOS)
      expect(model.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)
    end
  end

  describe "App object" do
    it 'finds app by bundle id' do
      model = Spaceship::ConnectAPI::App.find("com.joshholtz.FastlaneTest")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
    end

    it 'creates beta group' do
      app = Spaceship::ConnectAPI::App.find("com.joshholtz.FastlaneTest")

      model = app.create_beta_group(group_name: "Brand New Group", public_link_enabled: false, public_link_limit: 10_000, public_link_limit_enabled: false)
      expect(model.id).to eq("123456789")
    end

    it '#get_review_submissions' do
      ConnectAPIStubbing::Tunes.stub_get_review_submissions

      app = Spaceship::ConnectAPI::App.new("123456789-app", [])

      review_submissions = app.get_review_submissions
      expect(review_submissions.count).to eq(2)
      expect(review_submissions.first.id).to eq("123456789")
    end

    it '#create_review_submission' do
      ConnectAPIStubbing::Tunes.stub_create_review_submission

      app = Spaceship::ConnectAPI::App.new("123456789-app", [])

      review_submission = app.create_review_submission(platform: Spaceship::ConnectAPI::Platform::IOS)

      expect(review_submission.id).to eq("123456789")
      expect(review_submission.platform).to eq(Spaceship::ConnectAPI::Platform::IOS)
      expect(review_submission.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)
    end
  end
end
