// Mock request storage (replace with database in production)
let requests = [];
let nextRequestId = 1;

class Request {
  constructor({
    donationId,
    donorId,
    donorName,
    receiverId,
    receiverName,
    receiverEmail,
    receiverPhone = null,
    message = null,
    status = "pending",
  }) {
    this.id = nextRequestId++;
    this.donationId = donationId;
    this.donorId = donorId;
    this.donorName = donorName;
    this.receiverId = receiverId;
    this.receiverName = receiverName;
    this.receiverEmail = receiverEmail;
    this.receiverPhone = receiverPhone;
    this.message = message;
    this.status = status; // pending, approved, declined, completed, cancelled
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
    this.respondedAt = null;
  }

  static create(requestData) {
    const request = new Request(requestData);
    requests.push(request);
    return request;
  }

  static findAll(filters = {}) {
    let filteredRequests = requests;

    if (filters.donationId) {
      filteredRequests = filteredRequests.filter(
        (r) => r.donationId === parseInt(filters.donationId)
      );
    }

    if (filters.donorId) {
      filteredRequests = filteredRequests.filter(
        (r) => r.donorId === filters.donorId
      );
    }

    if (filters.receiverId) {
      filteredRequests = filteredRequests.filter(
        (r) => r.receiverId === filters.receiverId
      );
    }

    if (filters.status) {
      filteredRequests = filteredRequests.filter(
        (r) => r.status === filters.status
      );
    }

    return filteredRequests.sort(
      (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
    );
  }

  static findById(id) {
    return requests.find((r) => r.id === parseInt(id));
  }

  static findByDonorId(donorId) {
    return requests.filter((r) => r.donorId === donorId);
  }

  static findByReceiverId(receiverId) {
    return requests.filter((r) => r.receiverId === receiverId);
  }

  static findByDonationId(donationId) {
    return requests.filter((r) => r.donationId === parseInt(donationId));
  }

  static update(id, updateData) {
    const requestIndex = requests.findIndex((r) => r.id === parseInt(id));
    if (requestIndex === -1) return null;

    const updatedRequest = {
      ...requests[requestIndex],
      ...updateData,
      updatedAt: new Date().toISOString(),
    };

    // Set respondedAt when status changes from pending
    if (
      updateData.status &&
      requests[requestIndex].status === "pending" &&
      updateData.status !== "pending"
    ) {
      updatedRequest.respondedAt = new Date().toISOString();
    }

    requests[requestIndex] = updatedRequest;
    return updatedRequest;
  }

  static delete(id) {
    const requestIndex = requests.findIndex((r) => r.id === parseInt(id));
    if (requestIndex === -1) return false;

    requests.splice(requestIndex, 1);
    return true;
  }

  static getStats() {
    return {
      total: requests.length,
      pending: requests.filter((r) => r.status === "pending").length,
      approved: requests.filter((r) => r.status === "approved").length,
      declined: requests.filter((r) => r.status === "declined").length,
      completed: requests.filter((r) => r.status === "completed").length,
      cancelled: requests.filter((r) => r.status === "cancelled").length,
    };
  }

  // Check if a user has already requested a specific donation
  static hasUserRequestedDonation(receiverId, donationId) {
    return requests.some(
      (r) =>
        r.receiverId === receiverId &&
        r.donationId === parseInt(donationId) &&
        r.status !== "cancelled" &&
        r.status !== "declined"
    );
  }

  // Get pending requests for a donation
  static getPendingRequestsForDonation(donationId) {
    return requests.filter(
      (r) => r.donationId === parseInt(donationId) && r.status === "pending"
    );
  }
}

module.exports = Request;
