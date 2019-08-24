
  json.array! @notifications do |notification|
    json.id notification.id  
    #json.recipient notification.recipient
    json.actor do
      json.name notification.actor.name
      json.url institute_admin_path(notification.actor.institute, notification.actor)
    end
    json.action notification.action
    json.notifiable do 
      json.type "your #{notification.notifiable.class.to_s.underscore.humanize.downcase}"
      case notification.notifiable_type
        when 'Complaint'
          json.title notification.notifiable.title
          json.url city_complaint_path(@city, notification.notifiable)
        when 'Post'
          json.title notification.notifiable.title
          json.url subtopic_post_path(@city, notification.notifiable.topic, notification.notifiable.subtopic, notification.notifiable)
        when 'CityReview'
          json.title notification.notifiable.title
          json.url city_review_path(@city, notification.notifiable)
        when 'DepartmentReview'
          json.title notification.notifiable.title
          json.url city_department_review_path(@city, notification.notifiable)
        when 'Petition'
          json.title notification.notifiable.title
          json.url city_petition_path(@city, notification.notifiable)
        when 'Comment'
          tmp = notification.notifiable
          while tmp.commentable_type == 'Comment'
            tmp = tmp.commentable
          end
          case tmp.commentable_type
            when 'Complaint'
              json.title tmp.commentable.title
              json.url city_complaint_path(@city, tmp.commentable)
            when 'Post'
              json.title tmp.commentable.title
              json.url subtopic_post_path(@city, tmp.commentable.topic, tmp.commentable.subtopic, tmp.commentable)
            when 'CityReview'
              json.title tmp.commentable.title
              json.url city_review_path(@city, tmp.commentable)
            when 'DepartmentReview'
              json.title tmp.commentable.title
              json.url city_department_review_path(@city, tmp.commentable)
            when 'Petition'
              json.title tmp.commentable.title
              json.url city_petition_path(@city, tmp.commentable)
          end
      end
    end
    json.unread notification.read_at ? false : true
  end