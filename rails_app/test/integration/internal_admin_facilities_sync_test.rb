# frozen_string_literal: true

require "test_helper"

class InternalAdminFacilitiesSyncTest < ActionDispatch::IntegrationTest
  setup do
    @token = "test-facility-token-#{SecureRandom.hex(4)}"
    ENV["FLEXLINE_FACILITY_SYNC_TOKEN"] = @token
    @org = Organization.create!(
      name: "Facility API Co",
      importer_external_id: "facility-api-#{SecureRandom.hex(3)}",
      credit_limit_cents: 1_000_000,
      available_cents: 800_000,
      portal_status: "active"
    )
  end

  teardown do
    ENV.delete("FLEXLINE_FACILITY_SYNC_TOKEN")
  end

  test "sync updates limits with valid token" do
    post internal_admin_facilities_sync_path,
         params: {
           importer_external_id: @org.importer_external_id,
           credit_limit_cents: 2_000_000,
           available_cents: 500_000,
           portal_status: "suspended",
         }.to_json,
         headers: { "CONTENT_TYPE" => "application/json", "X-Flexline-Facility-Token" => @token }

    assert_response :success
    @org.reload
    assert_equal 2_000_000, @org.credit_limit_cents
    assert_equal 500_000, @org.available_cents
    assert_equal "suspended", @org.portal_status
  end

  test "sync rejects missing token" do
    post internal_admin_facilities_sync_path,
         params: { importer_external_id: @org.importer_external_id, available_cents: 1 }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :unauthorized
  end
end
