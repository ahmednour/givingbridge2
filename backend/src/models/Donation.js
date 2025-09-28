// Mock donation storage (replace with database in production)
let donations = [];
let nextDonationId = 1;

class Donation {
  constructor({
    title,
    description,
    category,
    condition,
    location,
    donorId,
    donorName,
    imageUrl = null,
    isAvailable = true,
  }) {
    this.id = nextDonationId++;
    this.title = title;
    this.description = description;
    this.category = category;
    this.condition = condition;
    this.location = location;
    this.donorId = donorId;
    this.donorName = donorName;
    this.imageUrl = imageUrl;
    this.isAvailable = isAvailable;
    this.createdAt = new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  static create(donationData) {
    const donation = new Donation(donationData);
    donations.push(donation);
    return donation;
  }

  static findAll(filters = {}) {
    let filteredDonations = donations;

    if (filters.category) {
      filteredDonations = filteredDonations.filter(
        (d) => d.category.toLowerCase() === filters.category.toLowerCase()
      );
    }

    if (filters.location) {
      filteredDonations = filteredDonations.filter((d) =>
        d.location.toLowerCase().includes(filters.location.toLowerCase())
      );
    }

    if (filters.isAvailable !== undefined) {
      filteredDonations = filteredDonations.filter(
        (d) => d.isAvailable === filters.isAvailable
      );
    }

    if (filters.donorId) {
      filteredDonations = filteredDonations.filter(
        (d) => d.donorId === filters.donorId
      );
    }

    return filteredDonations.sort(
      (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
    );
  }

  static findById(id) {
    return donations.find((d) => d.id === parseInt(id));
  }

  static findByDonorId(donorId) {
    return donations.filter((d) => d.donorId === donorId);
  }

  static update(id, updateData) {
    const donationIndex = donations.findIndex((d) => d.id === parseInt(id));
    if (donationIndex === -1) return null;

    donations[donationIndex] = {
      ...donations[donationIndex],
      ...updateData,
      updatedAt: new Date().toISOString(),
    };

    return donations[donationIndex];
  }

  static delete(id) {
    const donationIndex = donations.findIndex((d) => d.id === parseInt(id));
    if (donationIndex === -1) return false;

    donations.splice(donationIndex, 1);
    return true;
  }

  static getStats() {
    return {
      total: donations.length,
      available: donations.filter((d) => d.isAvailable).length,
      categories: {
        food: donations.filter((d) => d.category === "food").length,
        clothes: donations.filter((d) => d.category === "clothes").length,
        books: donations.filter((d) => d.category === "books").length,
        electronics: donations.filter((d) => d.category === "electronics")
          .length,
        other: donations.filter((d) => d.category === "other").length,
      },
    };
  }
}

module.exports = Donation;
