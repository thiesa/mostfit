class Fees < Application
  # provides :xml, :yaml, :js
  def index
    @fees = Fee.all
    display @fees
  end

  def show(id)
    @fee = Fee.get(id)
    raise NotFound unless @fee
    @trails = AuditTrail.all(:auditable_id => @fee.id, :auditable_type => "Fee", :order => [:created_at.desc])
    @obj = @fee
    display @fee
  end

  def new
    only_provides :html
    @fee = Fee.new
    display @fee
  end

  def edit(id)
    only_provides :html
    @fee = Fee.get(id)
    raise NotFound unless @fee
     display @fee
  end

  def create(fee)
    Fee.properties.select{|p| p.type == Integer or p.type == Float }.each{|f| fee[f.name] = nil if fee[f.name] == ""}
    fee[:percentage] = fee[:percentage].to_f/100 unless (fee[:percentage] == nil)
    @fee = Fee.new(fee)
    if @fee.save
      redirect resource(@fee), :message => {:notice => "Fee was successfully created"}
    else
      message[:error] = "Fee failed to be created"
      render :new
    end
  end

  def update(id, fee)
    debugger
    @fee = Fee.get(id)
    raise NotFound unless @fee
    fee[:percentage] = nil if fee[:percentage].to_f == 0.0
    fee[:percentage] = fee[:percentage].to_f/100 unless (fee[:percentage] == nil)
    Fee.properties.select{|p| p.type == Integer or p.type == Float }.each{|f| fee[f.name] = nil if fee[f.name] == ""}
    if @fee.update(fee)
       redirect resource(@fee)
    else
      display @fee, :edit
    end
  end

  def destroy(id)
    @fee = Fee.get(id)
    raise NotFound unless @fee
    if @fee.destroy
      redirect resource(:fees)
    else
      raise InternalServerError
    end
  end

end # Fees
